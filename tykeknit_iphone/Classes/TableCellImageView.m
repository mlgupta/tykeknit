//
//  TableCellImageView.m
//  TykeKnit
//
//  Created by Abhinav Singh on 12/01/11.
//  Copyright 2011 Vercingetorix Technologies. All rights reserved.
//

#import "TableCellImageView.h"
#import "TykeKnitApi.h"
#import <QuartzCore/QuartzCore.h>
#import "Global.h"


@implementation TableCellImageView
@synthesize str_imageURL, image, defaultImage;

- (id)initWithFrame:(CGRect)frame {
	
    self = [super initWithFrame:frame];
    if (self) {
		
		self.backgroundColor = [UIColor clearColor];
		self.layer.cornerRadius = 8.0;
		self.layer.borderWidth = 2.0;
		self.layer.borderColor = [UIColor clearColor].CGColor;
		self.clipsToBounds = YES;
		
		vi_loading = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		vi_loading.backgroundColor = [UIColor blackColor];
		vi_loading.layer.cornerRadius = 10;
		
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		indicator.tag = 123;
		CGRect rect = indicator.frame;
		rect.origin.x = (frame.size.width-rect.size.width)/2;
		rect.origin.y = (frame.size.height-rect.size.height)/2;
		indicator.frame = rect;
		[vi_loading addSubview:indicator];
		[indicator release];
		
		theImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		theImageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:theImageView];
		[theImageView release];
    }
	
    return self;
}

- (void) animationStopped {
	
	[vi_loading removeFromSuperview];
	[(UIActivityIndicatorView*)[vi_loading viewWithTag:123] stopAnimating];
}

- (void) stopLoading {
	
	[self animationStopped];
}

- (void) startLoading {
	
	[self addSubview:vi_loading];
	[(UIActivityIndicatorView*)[vi_loading viewWithTag:123] startAnimating];
}

- (void) setImageUrl:(NSString*)url {
	
	if (![self.str_imageURL isEqualToString:url]) {
		
		if ([url length]) {
			self.image = nil;
			TykeKnitApi *api_tyke = [[[TykeKnitApi alloc]init] autorelease];
			self.str_imageURL = [NSString stringWithFormat:@"%@%@",api_tyke.domain_URL, url];
			[self performSelectorInBackground:@selector(getDataForCurrentUrl) withObject:nil];
		}else {
			self.image = self.defaultImage;
		}
	}
}

- (void) getDataForCurrentUrl {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSData *urlData = nil;
	urlData = [NSData dataWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:md5(self.str_imageURL)]];
	if (!urlData || ![urlData length]) {
		
		NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.str_imageURL] 
																  cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
															  timeoutInterval:10.0];
		[theRequest setHTTPShouldHandleCookies:YES];
		[theRequest setHTTPMethod:@"GET"];
		NSURLResponse *theResponse = NULL;
		NSError *theError = NULL;
		urlData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&theError];
//		NSLog(@"%@, Lenght %d", self.str_imageURL, [urlData length]);
//		NSLog(@"Value %@", urlData);
//		NSLog(@"Response %@", [(NSHTTPURLResponse*)theResponse allHeaderFields]);
		if (urlData) {
			[urlData writeToFile:[DOC_DIR stringByAppendingPathComponent:md5(self.str_imageURL)] atomically:NO];
		}
	}
	
	UIImage *img = [[UIImage imageWithData:urlData] retain];
	if (img) {
		[self performSelectorOnMainThread:@selector(setImage:) withObject:img waitUntilDone:NO];
	}else {
		[self performSelectorOnMainThread:@selector(setImage:) withObject:self.defaultImage waitUntilDone:NO];
	}

	[pool release];
}


- (void) setImage : (UIImage*)img {

	if (img) {
		
		theImageView.image = img;
		[self stopLoading];
	}else {
//		[self startLoading];
	}
}

- (void)dealloc {
	
	[self.str_imageURL release];
	[self.image release];
    [super dealloc];
}

@end
