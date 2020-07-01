//
//  VVXTURLResponse.m
//  PhotoGallery
//
//  Created by Abhinit on 27/10/09.
//  Copyright 2009 Vercingetorix Tech. All rights reserved.
//

#import "VXTURLResponse.h"
#import "VXTURLRequest.h"
#import "VXTCache.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// Errors

#define VXT_ERROR_DOMAIN @"google.com"
#define VXT_EC_INVALID_IMAGE 101

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation VXTURLDataResponse

@synthesize data = _data;

- (id)init {
	if (self = [super init]) {
		_data = nil;
	}
	return self;
}

- (void)dealloc {
	[_data release];
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// VXTURLResponse

- (NSError*)request:(VXTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
			   data:(NSData*)data {
	_data = [data retain];
	return nil;
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation VXTURLImageResponse

@synthesize image = _image;

- (id)init {
	if (self = [super init]) {
		_image = nil;
	}
	return self;
}

- (void)dealloc {
	[_image release];
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// VXTURLResponse

- (NSError*)request:(VXTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
			   data:(NSData*)data {
	UIImage* image = [UIImage imageWithData:data];
	if (image) {
		if (!request.respondedFromCache) {
			[[VXTCache sharedCache] storeImage:image forKey:request.cacheKey];
		}
		_image = [image retain];
		return nil;
	} else {
		return [NSError errorWithDomain:VXT_ERROR_DOMAIN code:VXT_EC_INVALID_IMAGE
							   userInfo:nil];
	}
}

@end

