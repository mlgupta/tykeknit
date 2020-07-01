//
//  VVXTURLResponse.h
//  PhotoGallery
//
//  Created by Abhinit on 27/10/09.
//  Copyright 2009 Vercingetorix Tech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VXTURLRequest;
	
@protocol VXTURLResponse <NSObject>
	
/**
 * Processes the data from a successful request and determines if it is valid.
 *
 * If the data is not valid, return an error.  The data will not be cached if there is an error.
 */
- (NSError*)request:(VXTURLRequest*)request processResponse:(NSHTTPURLResponse*)response
data:(NSData*)data;

@end

@interface VXTURLDataResponse : NSObject <VXTURLResponse> {
	NSData* _data;
}

@property(nonatomic,readonly) NSData* data;

@end

@interface VXTURLImageResponse : NSObject <VXTURLResponse> {
	UIImage* _image;
}

@property(nonatomic,readonly) UIImage* image;

@end
