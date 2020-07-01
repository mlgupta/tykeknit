//
//  VXTURLRequestQueue.h
//  PhotoGallery
//
//  Created by Abhinit on 27/10/09.
//  Copyright 2009 Vercingetorix Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"

@class VXTURLRequest;
	
@interface VXTURLRequestQueue : NSObject {
	NSMutableDictionary* _loaders;
	NSMutableArray* _loaderQueue;
	NSTimer* _loaderQueueTimer;
	NSInteger _totalLoading;
	NSUInteger _maxContentLength;
	NSString* _userAgent;
	CGFloat _imageCompressionQuality;
	BOOL _suspended;
}

/**
 * Gets the flag that determines if new load requests are allowed to reach the network.
 *
 * Because network requests tend to slow down performance, this property can be used to
 * temporarily delay them.  All requests made while suspended are queued, and when 
 * suspended becomes false again they are executed.
 */
@property(nonatomic) BOOL suspended;

/**
 * The maximum size of a download that is allowed.
 *
 * If a response reports a content length greater than the max, the download will be
 * cancelled.  This is helpful for preventing excessive memory usage.  Setting this to 
 * zero will allow all downloads regardless of size.  The default is a relatively large value.
 */
@property(nonatomic) NSUInteger maxContentLength;

/**
 * The user-agent string that is sent with all HTTP requests.
 */
@property(nonatomic,copy) NSString* userAgent;

/**
 * The compression quality used for encoding images sent with HTTP posts.
 */
@property(nonatomic) CGFloat imageCompressionQuality;

/**
 * Gets the shared cache singleton used across the application.
 */
+ (VXTURLRequestQueue*)mainQueue;

/**
 * Sets the shared cache singleton used across the application.
 */
+ (void)setMainQueue:(VXTURLRequestQueue*)queue;

/**
 * Loads a request from the cache or the network if it is not in the cache.
 *
 * @return YES if the request was loaded synchronously from the cache.
 */
- (BOOL)sendRequest:(VXTURLRequest*)request;

/**
 * Cancels a request that is in progress.
 */
- (void)cancelRequest:(VXTURLRequest*)request;

/**
 * Cancels all active or pending requests whose delegate or response is an object.
 *
 * This is useful for when an object is about to be destroyed and you want to remove pointers
 * to it from active requests to prevent crashes when those pointers are later referenced.
 */
- (void)cancelRequestsWithDelegate:(id)delegate;

/**
 * Cancel all active or pending requests.
 */
- (void)cancelAllRequests;

@end