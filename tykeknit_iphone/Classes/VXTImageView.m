//
//  VXTImageView.m
//  PhotoGallery
//
//  Created by Abhinit on 27/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VXTImageView.h"
#import "VXTCache.h"
#import "VXTURLResponse.h"
#import <QuartzCore/QuartzCore.h>

//////////////////////////////////////////////////////////////////////////////////////////////////

@implementation VXTImageView
@synthesize delegate = _delegate, url = _url, defaultImage = _defaultImage, autoresizesToImage = _autoresizesToImage, tempRowID;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_delegate = nil;
		_request = nil;
		_url = nil;
		_defaultImage = nil;
		_autoresizesToImage = NO;
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super initWithCoder:decoder]) {
		_delegate = nil;
		_request = nil;
		_url = nil;
		_defaultImage = nil;
		_autoresizesToImage = NO;
	}
	return self;
}

- (void)dealloc {
	_delegate = nil;
	[_request cancel];
	[_request release];
	[_url release];
	[_defaultImage release];
	[super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// UIImageView

- (void)setImage:(UIImage*)image1 {
	[super setImage:image1];
	CGRect frame = self.frame;
	if (_autoresizesToImage) {
		self.frame = CGRectMake(frame.origin.x, frame.origin.y, image1.size.width, image1.size.height);
	} else {
		if (!frame.size.width && !frame.size.height) {
			self.frame = CGRectMake(frame.origin.x, frame.origin.y, image1.size.width, image1.size.height);
		} else if (frame.size.width && !frame.size.height) {
			self.frame = CGRectMake(frame.origin.x, frame.origin.y,
									frame.size.width, floor((image1.size.height/image1.size.width) * frame.size.width));
		} else if (frame.size.height && !frame.size.width) {
			self.frame = CGRectMake(frame.origin.x, frame.origin.y,
									floor((image1.size.width/image1.size.height) * frame.size.height), frame.size.height);
		}
	}
	
	[[self viewWithTag:1122] removeFromSuperview];
	if (!_defaultImage || ![image1 isEqual:_defaultImage]) {
		
/*		self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.5];
		self.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
		[UIView commitAnimations];*/
		
		[self imageViewDidLoadImage:image1];
		if ([_delegate respondsToSelector:@selector(imageView:didLoadImage:)]) {
			[_delegate imageView:self didLoadImage:image1];
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// VXURLRequestDelegate

- (void)requestDidStartLoad:(VXTURLRequest*)request {
	_request = [request retain];
	
	[self imageViewDidStartLoad];
	if ([_delegate respondsToSelector:@selector(imageViewDidStartLoad:)]) {
		[_delegate imageViewDidStartLoad:self];
	}
}

- (void)requestDidFinishLoad:(VXTURLRequest*)request {
	VXTURLImageResponse* response = request.response;
	[self performSelectorOnMainThread:@selector(setImage:) withObject:response.image waitUntilDone:NO];
	[_request release];
	_request = nil;
}

- (void) addNoImageLabel : (UIView*)vie {
	
	[[vie viewWithTag:2222] removeFromSuperview];
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (vie.frame.size.height/2.0)-10, vie.frame.size.width, 20)];
	label.tag = 2121;
	label.textColor = [UIColor whiteColor];
	label.font = [UIFont boldSystemFontOfSize:16];
	label.text = @"Sorry! Image Not Found.";
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = UITextAlignmentCenter;
	label.alpha = 0.0f;
	[vie addSubview:label];
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7];
    label.alpha = 1.0f;
    [UIView commitAnimations];
	[label release];
}

- (void)request:(VXTURLRequest*)request didFailLoadWithError:(NSError*)error {
	
	[_request release];
	_request = nil;
	UIView *vi = [self viewWithTag:1122];
	if (vi) {
		[self performSelectorOnMainThread:@selector(addNoImageLabel:) withObject:vi waitUntilDone:NO];
	}
	
//	[self imageViewDidFailLoadWithError:error];
//	if ([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
//		[_delegate imageView:self didFailLoadWithError:error];
//	}
}

- (void)requestDidCancelLoad:(VXTURLRequest*)request {
	[_request release];
	_request = nil;
	[self imageViewDidFailLoadWithError:nil];
	if ([_delegate respondsToSelector:@selector(imageView:didFailLoadWithError:)]) {
		[_delegate imageView:self didFailLoadWithError:nil];
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////
// public

- (void)setUrl:(NSString*)newUrl {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (self.image && _url && [newUrl isEqualToString:_url] && ![self.image isEqual:_defaultImage]){
		[pool release];
		return;
	}
	
	[self stopLoading];
	[_url release];
	_url = [newUrl retain];
	
	if (!_url || !_url.length) {
		if (![self.image isEqual:_defaultImage]) {
			[self performSelectorOnMainThread:@selector(setImage:) withObject:_defaultImage waitUntilDone:NO];
//			self.image = _defaultImage;
		}
	} else {
		[self reload];
	}
	
	[pool release];
}

- (BOOL)isLoading {
	return !!_request;
}

- (BOOL)isLoaded {
	return self.image && ![self.image isEqual:_defaultImage];
}

- (void)reload {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if (_request){
		[pool release];
		return;
	}
	UIImage* image = [[VXTCache sharedCache] imageForURL:_url];
	if (image) {
		[self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
	} else {
		VXTURLRequest* request = [VXTURLRequest requestWithURL:_url delegate:self];
		request.cachePolicy = VXTURLRequestCachePolicyDisk;
		request.response = [[[VXTURLImageResponse alloc] init] autorelease];
		if (_url && ![request send]) {
			// Put the default image in place while waiting for the request to load
			if (_defaultImage && ![self.image isEqual:_defaultImage]) {
				[self performSelectorOnMainThread:@selector(setImage:) withObject:_defaultImage waitUntilDone:NO];
			}
		}
	}
	
	[pool release];
}

- (void)stopLoading {
	[_request cancel];
}

- (void)imageViewDidStartLoad {
	
}

- (void)imageViewDidLoadImage:(UIImage*)image {
	
}

- (void)imageViewDidFailLoadWithError:(NSError*)error {
	
}

- (void) loadImageWithUrl:(NSString*)img_url{
	UIView *vi = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
	vi.backgroundColor = [UIColor blackColor];
	vi.layer.cornerRadius = 10.0f;
	vi.alpha = 0.9f;
	vi.tag = 1122;
	
	UIActivityIndicatorView *actVi = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((self.frame.size.width/2.0)-10, (self.frame.size.height/2.0)-10, 20, 20)];
	actVi.tag = 2222;
	[vi addSubview:actVi];
	[actVi startAnimating];
	[actVi release];
	[self addSubview:vi];
	[vi release];
	
	[self performSelectorInBackground:@selector(setUrl:) withObject:img_url];
}

@end
