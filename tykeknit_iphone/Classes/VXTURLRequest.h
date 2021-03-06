//
//  VXTURLRequest.h
//  PhotoGallery
//
//  Created by Abhinit on 27/10/09.
//  Copyright 2009 Vercingetorix Tech. All rights reserved.
//
#import "Global.h"
#import <Foundation/Foundation.h>

@protocol VXTURLRequestDelegate, VXTURLResponse;

@interface VXTURLRequest : NSObject {
	NSString* _url;
	NSString* _httpMethod;
	NSData* _httpBody;
	NSMutableDictionary* _parameters;
	NSString* _contentType;
	NSMutableArray* _delegates;
	id<VXTURLResponse> _response;
	VXTURLRequestCachePolicy _cachePolicy;
	NSTimeInterval _cacheExpirationAge;
	NSString* _cacheKey;
	NSString* _requestID;
	NSDate* _timestamp;
	id _userInfo;
	BOOL _isLoading;
	BOOL _shouldHandleCookies;
	BOOL _respondedFromCache;
}

/**
 * An object that receives messages about the progress of the request.
 */
@property(nonatomic,readonly) NSMutableArray* delegates;

/**
 * An object that handles the response data and may parse and validate it.
 */
@property(nonatomic,retain) id<VXTURLResponse> response;

/**
 * The URL to be loaded by the request.
 */
@property(nonatomic,copy) NSString* url;

/**
 * The HTTP method to send with the request.
 */
@property(nonatomic,copy) NSString* httpMethod;

/**
 * The HTTP body to send with the request.
 */
@property(nonatomic,readonly) NSData* httpBody;

/**
 * The content type of the data in the request.
 */
@property(nonatomic,copy) NSString* contentType;

/**
 * Parameters to use for an HTTP post.
 */
@property(nonatomic,readonly) NSMutableDictionary* parameters;

/**
 * Defaults to "any".
 */
@property(nonatomic) VXTURLRequestCachePolicy cachePolicy;

/**
 * The maximum age of cached data that can be used as a response.
 */
@property(nonatomic) NSTimeInterval cacheExpirationAge;

@property(nonatomic,retain) NSString* cacheKey;
@property(nonatomic,retain) NSString* requestID;

@property(nonatomic,retain) id userInfo;

@property(nonatomic,retain) NSDate* timestamp;

@property(nonatomic) BOOL isLoading;

@property(nonatomic) BOOL shouldHandleCookies;

@property(nonatomic) BOOL respondedFromCache;

+ (VXTURLRequest*)request;

+ (VXTURLRequest*)requestWithURL:(NSString*)url delegate:(id<VXTURLRequestDelegate>)delegate;

- (id)initWithURL:(NSString*)url delegate:(id<VXTURLRequestDelegate>)delegate;

/**
 * Attempts to send a request.
 *
 * If the request can be resolved by the cache, it will happen synchronously.  Otherwise,
 * the request will respond to its delegate asynchronously.
 *
 * @return YES if the request was loaded synchronously from the cache.
 */
- (BOOL)send;

/**
 * Cancels the request.
 *
 * If there are multiple requests going to the same URL as this request, the others will
 * not be cancelled.
 */
- (void)cancel;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol VXTURLRequestDelegate <NSObject>

@optional

/**
 * The request has begun loading.
 */
- (void)requestDidStartLoad:(VXTURLRequest*)request;

/**
 * The request has loaded data has loaded and been processed into a response.
 *
 * If the request is served from the cache, this is the only delegate method that will be called.
 */
- (void)requestDidFinishLoad:(VXTURLRequest*)request;

/**
 *
 */
- (void)request:(VXTURLRequest*)request didFailLoadWithError:(NSError*)error;

/**
 *
 */
- (void)requestDidCancelLoad:(VXTURLRequest*)request;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * A helper class for storing user info to help identify a request.
 *
 * This class lets you store both a strong reference and a weak reference for the duration of
 * the request.  The weak reference is special because VXTURLRequestQueue will examine it when
 * you call cancelRequestsWithDelegate to see if the weak object is the delegate in question.
 * For this reason, this object is a safe way to store an object that may be destroyed before
 * the request completes if you call cancelRequestsWithDelegate in the object's destructor.
 */
@interface VXTUserInfo : NSObject {
	NSString* _topic;
	id _strong;
	id _weak;
}

@property(nonatomic,retain) NSString* topic;
@property(nonatomic,retain) id strong;
@property(nonatomic,assign) id weak;

+ (id)topic:(NSString*)topic strong:(id)strong weak:(id)weak;
+ (id)topic:(NSString*)topic;
+ (id)weak:(id)weak;

- (id)initWithTopic:(NSString*)topic strong:(id)strong weak:(id)weak;

@end
