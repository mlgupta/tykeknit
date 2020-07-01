//
//  Global.m
//  PhotoGallery
//
//  Created by Abhinit on 27/10/09.
//  Copyright 2009 Vercingetorix Tech. All rights reserved.
//

#import "Global.h"
#import <CommonCrypto/CommonDigest.h>

///////////////////////////////////////////////////////////////////////////////////////////////////

static int gNetworkTaskCount = 0;

static const void* VXTRetainNoOp(CFAllocatorRef allocator, const void *value) { return value; }
static void VXTReleaseNoOp(CFAllocatorRef allocator, const void *value) { }

NSString* md5(NSString *str) {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    return [NSString stringWithFormat: @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",                     
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]];
}

NSInteger getAge(NSDate *dateOfBirth) {
	
	NSCalendar *calendar = [NSCalendar currentCalendar];
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
	NSDateComponents *dateComponentsNow = [calendar components:unitFlags fromDate:[NSDate date]];
	NSDateComponents *dateComponentsBirth = [calendar components:unitFlags fromDate:dateOfBirth];
	
	if (([dateComponentsNow month] < [dateComponentsBirth month]) ||
		(([dateComponentsNow month] == [dateComponentsBirth month]) && ([dateComponentsNow day] < [dateComponentsBirth day]))) {
		return [dateComponentsNow year] - [dateComponentsBirth year] - 1;
	} else {
		return [dateComponentsNow year] - [dateComponentsBirth year];
	}
}

NSString* getChildAge(NSString *childAge) {
	NSString *str = @"";
	NSString *age = nil;
	if (childAge.length > 7) {
 	str =  [childAge substringToIndex:8];
	}

	if ([childAge rangeOfString:@"years"].length && ![[childAge substringWithRange:NSMakeRange(1, 1)] isEqualToString:@" "]) {
		age = [childAge substringToIndex:2];
	}else {
		age = [childAge substringToIndex:1];
	}
	if ([str rangeOfString:@"mons"].length) {
		age = @"1"; 
	}
	return age;
}



NSString* VXTPathForBundleResource(NSString* relativePath) {
	NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
	return [resourcePath stringByAppendingPathComponent:relativePath];
}

NSString* VXTPathForDocumentsResource(NSString* relativePath) {
	static NSString* documentsPath = nil;
	if (!documentsPath) {
		NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentsPath = [[dirs objectAtIndex:0] retain];
	}
	return [documentsPath stringByAppendingPathComponent:relativePath];
}

void TxtLog(NSMutableString *logText) {
	if(![[NSFileManager defaultManager] fileExistsAtPath:VXTPathForDocumentsResource(@"log.txt")]) {
		[[NSFileManager defaultManager] createFileAtPath:VXTPathForDocumentsResource(@"log.txt") contents:nil attributes:nil];
	}
	
	NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:VXTPathForDocumentsResource(@"log.txt")];
	[fh seekToEndOfFile];
	
	[fh writeData:[[[NSDate date] description] dataUsingEncoding:NSUTF8StringEncoding]];
	[fh writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[fh writeData:[logText dataUsingEncoding:NSUTF8StringEncoding]];
	[fh writeData:[@"\n------------------------\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[fh closeFile];
}

NSMutableArray* VXTCreateNonRetainingArray() {
	CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
	callbacks.retain = VXTRetainNoOp;
	callbacks.release = VXTReleaseNoOp;
	return (NSMutableArray*)CFArrayCreateMutable(nil, 0, &callbacks);
}


//////////////////////////////////////////////////////////////////////////////////////////////////
UIDeviceOrientation VXTDeviceOrientation() {
	UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
	if (!orient) {
		return UIDeviceOrientationPortrait;
	} else {
		return orient;
	}
}

CGRect VXTNavigationFrame() {
	CGRect frame = [UIScreen mainScreen].applicationFrame;
	return CGRectMake(0, 0, frame.size.width, frame.size.height - VXTToolbarHeight());
}

UIInterfaceOrientation VXTInterfaceOrientation() {
	UIDeviceOrientation orient = [UIDevice currentDevice].orientation;
	if (!orient) {
		return UIDeviceOrientationPortrait;
	} else {
		return orient;
	}
}

void VXTNetworkRequestStarted() {
	if (gNetworkTaskCount++ == 0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	}
}

void VXTNetworkRequestStopped() {
	if (--gNetworkTaskCount == 0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
}

CGRect VXTScreenBounds() {
	CGRect bounds = [UIScreen mainScreen].bounds;
	if (UIInterfaceOrientationIsLandscape(VXTInterfaceOrientation())) {
		CGFloat width = bounds.size.width;
		bounds.size.width = bounds.size.height;
		bounds.size.height = width;
	}
	return bounds;
}

BOOL VXTIsSupportedOrientation(UIInterfaceOrientation orientation) {
	switch (orientation) {
		case UIInterfaceOrientationPortrait:
		case UIInterfaceOrientationLandscapeLeft:
		case UIInterfaceOrientationLandscapeRight:
			return YES;
		default:
			return NO;
	}
}

CGFloat VXTToolbarHeight() {
	return VXTToolbarHeightForOrientation(VXTInterfaceOrientation());
}

CGFloat VXTToolbarHeightForOrientation(UIInterfaceOrientation orientation) {
	if (UIInterfaceOrientationIsPortrait(orientation)) {
		return VXT_ROW_HEIGHT;
	} else {
		return VXT_LANDSCAPE_TOOLBAR_HEIGHT;
	}
}

CGAffineTransform VXTRotateTransformForOrientation(UIInterfaceOrientation orientation) {
	if (orientation == UIInterfaceOrientationLandscapeLeft) {
		return CGAffineTransformMakeRotation(M_PI*1.5);
	} else if (orientation == UIInterfaceOrientationLandscapeRight) {
		return CGAffineTransformMakeRotation(M_PI/2);
	} else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
		return CGAffineTransformMakeRotation(-M_PI);
	} else {
		return CGAffineTransformIdentity;
	}
}
