//
//  VXTURLRequestQueue.m
//  PhotoGallery
//
//  Created by Abhinit on 27/10/09.
//  Copyright 2009 Vercingetorix Tech. All rights reserved.
//

#import "VXTURLRequestQueue.h"
#import "VXTURLRequest.h"
#import "VXTURLResponse.h"
#import "VXTCache.h"
#import "NSObjectAdditions.h"

//////////////////////////////////////////////////////////////////////////////////////////////////

static const NSTimeInterval kFlushDelay = 0.3;
static const NSTimeInterval kTimeout = 5.0;
static const NSInteger kLoadMaxRetries = 2;
static const NSInteger kMaxConcurrentLoads = 5;
static NSUInteger kDefaultMaxContentLength = 150000;

static NSString* kSafariUserAgent = @"Mozilla/5.0 (iPhone; U; CPU iPhone OS 2_2 like Mac OS X;\
en-us) AppleWebKit/525.181 (KHTML, like Gecko) Version/3.1.1 Mobile/5H11 Safari/525.20";
//static NSString* kTykeUserAgent = @"TykeKnit/1.0";

static VXTURLRequestQueue* gMainQueue = nil;

//////////////////////////////////////////////////////////////////////////////////////////////////

@interface VXTRequestLoader : NSObject {
	NSString* _url;
	VXTURLRequestQueue* _queue;
	NSString* _cacheKey;
	VXTURLRequestCachePolicy _cachePolicy;
	NSTimeInterval _cacheExpirationAge;
	NSMutableArray* _requests;
	NSURLConnection* _connection;
	NSHTTPURLResponse* _response;
	NSMutableData* _responseData;
	int _retriesLeft;
	BOOL gotResponse;
}

@property(nonatomic,readonly) NSArray* requests;
@property(nonatomic,readonly) NSString* url;
@property(nonatomic,readonly) NSString* cacheKey;
@property(nonatomic,readonly) VXTURLRequestCachePolicy cachePolicy;
@property(nonatomic,readonly) NSTimeInterval cacheExpirationAge;
@property(nonatomic,readonly) BOOL isLoading;

- (id)initForRequest:(VXTURLRequest*)request queue:(VXTURLRequestQueue*)queue;

- (void)addRequest:(VXTURLRequest*)request;
- (void)removeRequest:(VXTURLRequest*)request;

- (void)load;
- (BOOL)cancel:(VXTURLRequest*)request;

@end

@implementation VXTRequestLoader

@synthesize url = _url, requests = _requests, cacheKey = _cacheKey,
cachePolicy = _cachePolicy, cacheExpirationAge = _cacheExpirationAge;

- (id)initForRequest:(VXTURLRequest*)request queue:(VXTURLRequestQueue*)queue {
	if (self = [super init]) {
		_url = [request.url copy];
		_queue = queue;
		_cacheKey = [request.cacheKey copy];
		_cachePolicy = request.cachePolicy;
		_cacheExpirationAge = request.cacheExpirationAge;
		_requests = [[NSMutableArray alloc] init];
		_connection = nil;
		_retriesLeft = kLoadMaxRetries;
		_response = nil;
		_responseData = nil;
		[self addRequest:request];
	}
	return self;
}

- (void)dealloc {
	[_connection cancel];
	[_connection release];
	[_response release];
	[_responseData release];
	[_url release];
	[_cacheKey release];
	[_requests release];
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)connectToURL:(NSURL*)url {
	VXTNetworkRequestStarted();
	gotResponse = NO;
	//NSLog(@"Request sent For URL : %@", [url absoluteString]);
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url
															  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
														  timeoutInterval:kTimeout];
	[urlRequest setValue:_queue.userAgent forHTTPHeaderField:@"User-Agent"];
	
	if (_requests.count == 1) {
		VXTURLRequest* request = [_requests objectAtIndex:0];
		[urlRequest setHTTPShouldHandleCookies:request.shouldHandleCookies];
		
		NSString* method = request.httpMethod;
		if (method) {
			[urlRequest setHTTPMethod:method];
		}
		
		NSString* contentType = request.contentType;
		if (contentType) {
			[urlRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
		}
		
		NSData* body = request.httpBody;
		if (body) {
			[urlRequest setHTTPBody:body];
		}
	}
	
	_connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
	
	//Changed By Abhinav Reason:Not Working when Started From Different Thread.
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	if(_connection)	{
		[_connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		while(!gotResponse) {
			if (![[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:100000]]) {
				break;
			}		
			[pool release];
			pool = [[NSAutoreleasePool alloc] init];
		}
		[pool release];
	}	
}

- (void)cancel {
	NSArray* requestsToCancel = [_requests copy];
	for (id request in requestsToCancel) {
		[self cancel:request];
	}
	[requestsToCancel release];
}

- (NSError*)processResponse:(NSHTTPURLResponse*)response data:(NSData*)data {
	
	for (VXTURLRequest* request in _requests) {
		NSError* error = [request.response request:request processResponse:response data:data];
		if (error) {
			return error;
		}
	}
	
	return nil;
}

- (void)dispatchLoaded:(NSDate*)timestamp {
	for (VXTURLRequest* request in [[_requests copy] autorelease]) {
		request.timestamp = timestamp;
		request.isLoading = NO;
		
		for (id<VXTURLRequestDelegate> delegate in request.delegates) {
			if ([delegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
				[delegate requestDidFinishLoad:request];
			}
		}
	}
}

- (void)dispatchError:(NSError*)error {
	for (VXTURLRequest* request in [[_requests copy] autorelease]) {
		request.isLoading = NO;
		
		for (id<VXTURLRequestDelegate> delegate in request.delegates) {
			if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
				[delegate request:request didFailLoadWithError:error];
			}
		}
	}
}

- (void)loadFromBundle:(NSURL*)url {
	NSString* path = nil;
	if (url.path.length) {
		NSString* fileName = [url.path substringFromIndex:1];
		path = [[NSBundle mainBundle] pathForResource:fileName ofType:nil inDirectory:url.host];
	} else {
		path = [[NSBundle mainBundle] pathForResource:url.host ofType:nil];
	}
	
	NSFileManager* fm = [NSFileManager defaultManager];
	if (path && [fm fileExistsAtPath:path]) {
		NSData* data = [NSData dataWithContentsOfFile:path];
		[_queue performSelector:@selector(loader:didLoadResponse:data:) withObject:self withObject:nil withObject:data];
	} else {
		NSError* error = [NSError errorWithDomain:NSCocoaErrorDomain
											 code:NSFileReadNoSuchFileError userInfo:nil];
		[_queue performSelector:@selector(loader:didFailLoadWithError:) withObject:self
					 withObject:error];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response {
	
	//NSLog(@"Connection : DidReceiveResponse");
	_response = [response retain];
	NSDictionary* headers = [response allHeaderFields];
	int contentLength = [[headers objectForKey:@"Content-Length"] intValue];
	if (contentLength > _queue.maxContentLength && _queue.maxContentLength) {
		[self cancel];
	}
	
	_responseData = [[NSMutableData alloc] initWithCapacity:contentLength];
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
	//NSLog(@"Connection : DidReceiveData");
	[_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection 
				  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
	VXTNetworkRequestStopped();
	
	if (_response.statusCode == 200) {
		[_queue performSelector:@selector(loader:didLoadResponse:data:) withObject:self
					 withObject:_response withObject:_responseData];
	} else {
		//NSLog(@"  FAILED LOADING (%d) %@", _response.statusCode, _url);
		NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:_response.statusCode
										 userInfo:nil];
		[_queue performSelector:@selector(loader:didFailLoadWithError:) withObject:self
					 withObject:error];
	}
	
	gotResponse = YES;
	[_responseData release];
	_responseData = nil;
	[_connection release];
	_connection = nil;
}

//testData
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	
	if ([challenge previousFailureCount] == 0) {
        NSURLCredential *newCredential;
        newCredential= [NSURLCredential credentialWithUser:@"thegeneralpublic" password:@"4fingers" persistence:NSURLCredentialPersistenceForSession];
        [challenge.sender useCredential:newCredential forAuthenticationChallenge:challenge];
    }else {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
    }
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
	VXTNetworkRequestStopped();
	[_responseData release];
	_responseData = nil;
	[_connection release];
	_connection = nil;
	
	if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCannotFindHost
		&& _retriesLeft) {
		// If there is a network error then we will wait and retry a few times just in case
		// it was just a temporary blip in connectivity
		--_retriesLeft;
		[self load];
	} else {
		[_queue performSelector:@selector(loader:didFailLoadWithError:) withObject:self withObject:error];
	}
	
	gotResponse = YES;
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)isLoading {
	return !!_connection;
}

- (void)addRequest:(VXTURLRequest*)request {
	[_requests addObject:request];
}

- (void)removeRequest:(VXTURLRequest*)request {
	[_requests removeObject:request];
}

- (void)load {
	if (!_connection) {
		NSURL* url = [NSURL URLWithString:_url];
		if ([url.scheme isEqualToString:@"bundle"]) {
			[self loadFromBundle:url];
		} else {
			[self connectToURL:url];
		}
	}
}

- (BOOL)cancel:(VXTURLRequest*)request {
	NSUInteger index = [_requests indexOfObject:request];
	if (index != NSNotFound) {
		[_requests removeObjectAtIndex:index];
		
		request.isLoading = NO;
		
		for (id<VXTURLRequestDelegate> delegate in request.delegates) {
			if ([delegate respondsToSelector:@selector(requestDidCancelLoad:)]) {
				[delegate requestDidCancelLoad:request];
			}
		}
	}
	if (![_requests count]) {
		[_queue performSelector:@selector(loaderDidCancel:wasLoading:) withObject:self
					 withObject:(id)!!_connection];
		if (_connection) {
			VXTNetworkRequestStopped();
			[_connection cancel];
			_connection = nil;
		}
		return NO;
	} else {
		return YES;
	}
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation VXTURLRequestQueue

@synthesize maxContentLength = _maxContentLength, userAgent = _userAgent, suspended = _suspended,
imageCompressionQuality = _imageCompressionQuality;

+ (VXTURLRequestQueue*)mainQueue {
	if (!gMainQueue) {
		gMainQueue = [[VXTURLRequestQueue alloc] init];
	}
	return gMainQueue;
}

+ (void)setMainQueue:(VXTURLRequestQueue*)queue {
	if (gMainQueue != queue) {
		[gMainQueue release];
		gMainQueue = [queue retain];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (id)init {
	if (self == [super init]) {
		_loaders = [[NSMutableDictionary alloc] init];
		_loaderQueue = [[NSMutableArray alloc] init];
		_loaderQueueTimer = nil;
		_totalLoading = 0;
		_maxContentLength = kDefaultMaxContentLength;
		_imageCompressionQuality = 0.75;
		_userAgent = [kSafariUserAgent copy];
		_suspended = NO;
	}
	return self;
}

- (void)dealloc {
	[_loaders release];
	[_loaderQueue release];
	[_loaderQueueTimer invalidate];
	[_userAgent release];
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)loadFromCache:(NSString*)url cacheKey:(NSString*)cacheKey
			  expires:(NSTimeInterval)expirationAge fromDisk:(BOOL)fromDisk data:(NSData**)data
			timestamp:(NSDate**)timestamp {
	if (fromDisk) {
		*data = [[VXTCache sharedCache] dataForKey:cacheKey expires:expirationAge
										   timestamp:timestamp];
		if (*data) {
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)loadRequestFromCache:(VXTURLRequest*)request {
	if (request.cachePolicy & (VXTURLRequestCachePolicyDisk|VXTURLRequestCachePolicyMemory)) {
		NSData* data = nil;
		NSDate* timestamp = nil;
		
		if ([self loadFromCache:request.url cacheKey:request.cacheKey
						expires:request.cacheExpirationAge
					   fromDisk:!_suspended && request.cachePolicy & VXTURLRequestCachePolicyDisk
						   data:&data timestamp:&timestamp]) {
			request.respondedFromCache = YES;
			request.timestamp = timestamp;
			request.isLoading = NO;
			
			NSError* error = [request.response request:request processResponse:nil data:data];
			if (error) {
				for (id<VXTURLRequestDelegate> delegate in request.delegates) {
					if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
						[delegate request:request didFailLoadWithError:error];
					}
				}
			} else {
				for (id<VXTURLRequestDelegate> delegate in request.delegates) {
					if ([delegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
						[delegate requestDidFinishLoad:request];
					}
				}
			}
			
			return YES;
		}
	}
	
	return NO;
}

- (void)executeLoader:(VXTRequestLoader*)loader {
	NSData* data = nil;
	NSDate* timestamp = nil;
	BOOL canUseCache = loader.cachePolicy
    & (VXTURLRequestCachePolicyDisk|VXTURLRequestCachePolicyMemory);
	
	if (canUseCache
		&& [self loadFromCache:loader.url cacheKey:loader.cacheKey
					   expires:loader.cacheExpirationAge
					  fromDisk:loader.cachePolicy & VXTURLRequestCachePolicyDisk
						  data:&data timestamp:&timestamp]) {
		NSError* error = [loader processResponse:nil data:data];
		if (error) {
			[loader dispatchError:error];
		} else {
			[loader dispatchLoaded:timestamp];
		}
		
		[_loaders removeObjectForKey:loader.cacheKey];
	} else {
		++_totalLoading;
		[loader load];
	}
}

- (void)loadNextInQueueDelayed {
	if (!_loaderQueueTimer) {
		_loaderQueueTimer = [NSTimer scheduledTimerWithTimeInterval:kFlushDelay target:self
														   selector:@selector(loadNextInQueue) userInfo:nil repeats:NO];
	}
}

- (void)loadNextInQueue {
	_loaderQueueTimer = nil;
	
	for (int i = 0;
		 i < kMaxConcurrentLoads && _totalLoading < kMaxConcurrentLoads
		 && _loaderQueue.count;
		 ++i) {
		VXTRequestLoader* loader = [[_loaderQueue objectAtIndex:0] retain];
		[_loaderQueue removeObjectAtIndex:0];
		[self executeLoader:loader];
		[loader release];
	}
	
	if (_loaderQueue.count) {
		[self loadNextInQueueDelayed];
	}
}

- (void)loadNextInQueueAfterLoader:(VXTRequestLoader*)loader {
	--_totalLoading;
	[_loaders removeObjectForKey:loader.cacheKey];
	[self loadNextInQueue];
}

- (void)loader:(VXTRequestLoader*)loader didLoadResponse:(NSHTTPURLResponse*)response
		  data:(NSData*)data {
	NSError* error = [loader processResponse:response data:data];
	if (error) {
		[loader dispatchError:error];
	} else {
		if (!(loader.cachePolicy & VXTURLRequestCachePolicyNoCache)) {
			[[VXTCache sharedCache] storeData:data forKey:loader.cacheKey];
		}
		[loader dispatchLoaded:[NSDate date]];
	}
	
	[self loadNextInQueueAfterLoader:loader];
}

- (void)loader:(VXTRequestLoader*)loader didFailLoadWithError:(NSError*)error {
	[loader dispatchError:error];
	[self loadNextInQueueAfterLoader:loader];
}

- (void)loaderDidCancel:(VXTRequestLoader*)loader wasLoading:(BOOL)wasLoading {
	if (wasLoading) {
		[self loadNextInQueueAfterLoader:loader];
	} else {
		[_loaders removeObjectForKey:loader.cacheKey];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////

- (void)setSuspended:(BOOL)isSuspended {

	_suspended = isSuspended;
	if (!_suspended) {
		[self loadNextInQueue];
	} else if (_loaderQueueTimer) {
		[_loaderQueueTimer invalidate];
		_loaderQueueTimer = nil;
	}
}

- (BOOL)sendRequest:(VXTURLRequest*)request {
	if (!request.cacheKey) {
		request.cacheKey = [[VXTCache sharedCache] keyForURL:request.url];
	}
	
	for (id<VXTURLRequestDelegate> delegate in request.delegates) {
		if ([delegate respondsToSelector:@selector(requestDidStartLoad:)]) {
			[delegate requestDidStartLoad:request];
		}
	}
	
	if ([self loadRequestFromCache:request]) {
		return YES;
	}
	
	if (!request.url) {
		NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
		for (id<VXTURLRequestDelegate> delegate in request.delegates) {
			if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
				[delegate request:request didFailLoadWithError:error];
			}
		}
		return NO;
	}
	
	request.isLoading = YES;
	VXTRequestLoader* loader = nil;
	if (![request.httpMethod isEqualToString:@"POST"]) {
		// Next, see if there is an active loader for the URL and if so join that bandwagon
		loader = [_loaders objectForKey:request.cacheKey];
		if (loader) {
			[loader addRequest:request];
			return NO;
		}
	}
	
	// Finally, create a new loader and hit the network (unless we are suspended)
	loader = [[VXTRequestLoader alloc] initForRequest:request queue:self];
	[_loaders setObject:loader forKey:request.cacheKey];
	if (_suspended || _totalLoading == kMaxConcurrentLoads) {
		[_loaderQueue addObject:loader];
	} else {
		++_totalLoading;
		[loader load];
	}
	[loader release];
	
	return NO;
}

- (void)cancelRequest:(VXTURLRequest*)request {
	if (request) {
		VXTRequestLoader* loader = [_loaders objectForKey:request.cacheKey];
		if (loader) {
			[loader retain];
			if (![loader cancel:request]) {
				[_loaderQueue removeObject:loader];
			}
			[loader release];
		}
	}
}

- (void)cancelRequestsWithDelegate:(id)delegate {
	NSMutableArray* requestsToCancel = nil;
	
	for (VXTRequestLoader* loader in [_loaders objectEnumerator]) {
		for (VXTURLRequest* request in loader.requests) {
			for (id<VXTURLRequestDelegate> requestDelegate in request.delegates) {
				if (delegate == requestDelegate) {
					if (!requestsToCancel) {
						requestsToCancel = [NSMutableArray array];
					}
					[requestsToCancel addObject:request];
					break;
				}
			}
			
			if ([request.userInfo isKindOfClass:[VXTUserInfo class]]) {
				VXTUserInfo* userInfo = request.userInfo;
				if (userInfo.weak && userInfo.weak == delegate) {
					if (!requestsToCancel) {
						requestsToCancel = [NSMutableArray array];
					}
					[requestsToCancel addObject:request];
				}
			}
		}
	}
	
	for (VXTURLRequest* request in requestsToCancel) {
		[self cancelRequest:request];
	}  
}

- (void)cancelAllRequests {
	for (VXTRequestLoader* loader in [[[_loaders copy] autorelease] objectEnumerator]) {
		[loader cancel];
	}
}

@end

