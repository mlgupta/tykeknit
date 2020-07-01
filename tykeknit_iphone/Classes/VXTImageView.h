//
//  VXTImageView.h
//  PhotoGallery
//
//  Created by Abhinit on 27/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VXTURLRequest.h"

@protocol VXTImageViewDelegate;

@interface VXTImageView : UIImageView <VXTURLRequestDelegate> {
	id<VXTImageViewDelegate> _delegate;
	VXTURLRequest* _request;
	NSString* _url;
	UIImage* _defaultImage;
	BOOL _autoresizesToImage;
	int tempRowID;
}

@property(nonatomic,assign) id<VXTImageViewDelegate> delegate;
@property(nonatomic,copy) NSString* url;
@property(nonatomic,retain) UIImage* defaultImage;
@property(nonatomic) BOOL autoresizesToImage;
@property(nonatomic,readonly) BOOL isLoading;
@property(nonatomic,readonly) BOOL isLoaded;
@property(nonatomic,assign) int tempRowID;

- (void)reload;
- (void)stopLoading;
- (void) loadImageWithUrl:(NSString*)img_url;

- (void)imageViewDidStartLoad;
- (void)imageViewDidLoadImage:(UIImage*)image;
- (void)imageViewDidFailLoadWithError:(NSError*)error;

@end

///////////////////////////////////////////////////////////////////////////////////////////////////

@protocol VXTImageViewDelegate <NSObject>

@optional

- (void)imageView:(VXTImageView*)imageView didLoadImage:(UIImage*)image;
- (void)imageViewDidStartLoad:(VXTImageView*)imageView;
- (void)imageView:(VXTImageView*)imageView didFailLoadWithError:(NSError*)error;

@end
