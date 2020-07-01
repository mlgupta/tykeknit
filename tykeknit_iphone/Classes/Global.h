//
//  Global.h
//  PhotoGallery
//
//  Created by Abhinit on 27/10/09.
//  Copyright 2009 Vercingetorix Tech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VXTCache.h"
#import "TykeKnitAppDelegate.h"

///////////////////////////////////////////////////////////////////////////////////////////////////
// Logging Helpers

#define DEBUG 0

#ifdef DEBUG
#define VXTLOG NSLog
#else
#define VXTLOG 
#endif

#define OS_VERSION [[UIDevice currentDevice] systemVersion]

#define VXTLOGRECT(rect) \
VXTLOG(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
rect.size.width, rect.size.height)

#define VXTLOGPOINT(pt) \
VXTLOG(@"%s x=%f, y=%f", #pt, pt.x, pt.y)

#define VXTLOGSIZE(size) \
VXTLOG(@"%s w=%f, h=%f", #size, size.width, size.height)

#define VXTLOGEDGES(edges) \
VXTLOG(@"%s left=%f, right=%f, top=%f, bottom=%f", #edges, edges.left, edges.right, \
edges.top, edges.bottom)

#define VXTIMAGE(_URL) [[VXTCache sharedCache] imageForURL:_URL]

#define VXT_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define VXT_AUTORELEASE_SAFELY(__POINTER) { [__POINTER autorelease]; __POINTER = nil; }
#define VXT_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

#define VXT_ROW_HEIGHT 44
#define VXT_TOOLBAR_HEIGHT 44
#define VXT_LANDSCAPE_TOOLBAR_HEIGHT 33
#define VXT_KEYBOARD_HEIGHT 216
#define VXT_LANDSCAPE_KEYBOARD_HEIGHT 160
#define VXT_ROUNDED -1

#define PAGE_FLIP_DURATION_FOR_ROOTVIEW 1
#define PAGE_FLIP_DURATION 0.5
#define DELEGATE ((TykeKnitAppDelegate*)[[UIApplication sharedApplication] delegate])
#define DOC_DIR [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define Cache_Default_Time (6*60*60)
#define DEVELOPER_VERSION 1

//#define DOMAIN_URL @"http://tykeknit.com/api" 
//#define DOMAIN_URL @"http://api.tykeknit.com/api"

#define faceBookAppID @"163369157007321"
#define faceBookApiKey @"617f8588ea1de65f90b4effe5c4bc9f0"
#define faceBookSecretKey @"bfde2b414092a5d06accea137e3c466f"

#define NOTIFY_MESSAGE_LIST_CHANGED @"messageListChanged"
#define ZIP_CODE_CHANGED @"zipCode Changed"
#define PROFILE_PIC_CHANGED @"profile pic Changed"

#define Trans_Duration 0.75
#define degreesToRadians(x) (M_PI * x / 180.0)
#define FAKE_DATA 0

#define grayLabelColor [UIColor colorWithRed:0.627 green:0.612 blue:0.616 alpha:1.0]

#define SectionHeaderColor [UIColor colorWithRed:0.298 green:0.337 blue:0.423 alpha:1.0]


#define WannaHangColor [UIColor colorWithRed:0.369 green:0.616 blue:0.192 alpha:1.0]
#define BoyBlueColor [UIColor colorWithRed:0.0901 green:0.7058 blue:0.9647 alpha:1.0]
#define GirlPinkColor [UIColor colorWithRed:0.8784 green:0.09451 blue:0.7215 alpha:1.0]

#define blueTextColor [UIColor colorWithRed:0.263 green:0.302 blue:0.392 alpha:1.0]
#define lightBlueTextColor [UIColor colorWithRed:0.204 green:0.318 blue:0.525 alpha:1.0]
#define tableBackgroundColor [UIColor colorWithRed:0.875 green:0.906 blue:0.918 alpha:1.0]
#define cellBackgroundColor [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0]




///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Creates a mutable array which does not retain references to the objects it contains.
*/

NSMutableArray* VXTCreateNonRetainingArray();

///////////////////////////////////////////////////////////////////////////////////////////////////
// Networking

typedef enum {
	VXTURLRequestCachePolicyNone = 0,
	VXTURLRequestCachePolicyMemory = 1,
	VXTURLRequestCachePolicyDisk = 2,
	VXTURLRequestCachePolicyNetwork = 4,
	VXTURLRequestCachePolicyAny = (VXTURLRequestCachePolicyMemory|VXTURLRequestCachePolicyDisk|VXTURLRequestCachePolicyNetwork),VXTURLRequestCachePolicyNoCache = 8,
	VXTURLRequestCachePolicyDefault = VXTURLRequestCachePolicyAny,
} VXTURLRequestCachePolicy;
///////////////////////////////////////////////////////////////////////////////////////////////////

static inline void logResponseData(NSData *data){
	NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	NSLog(@"logResponseData %@", str);
}

static inline NSString* DefaultIntValue(NSString* str){
	if(str == nil || [str length] < 1){
		str = @"0";
	}
	return str;
}

static inline NSString* formattedNilValue(NSString* str){
	if(str == nil || [str length] < 1){
		str = @"";
	}
	return str;
}

static inline NSString* removeGarbage(NSString* str){
	
	if(str == nil || [str length] < 1){
		str = @"";
	}
	
	str = [str stringByReplacingOccurrencesOfString:@"&lt;"  withString:@"<"];
	str = [str stringByReplacingOccurrencesOfString:@"&gt;"  withString:@">"];
	str = [str stringByReplacingOccurrencesOfString:@"&quot;" withString:@""""];
	str = [str stringByReplacingOccurrencesOfString:@"&#039;"  withString:@"'"];
	str = [str stringByReplacingOccurrencesOfString:@"&amp;amp;" withString:@"&"];
	str = [str stringByReplacingOccurrencesOfString:@"&amp;#38;" withString:@"&"];
	str = [str stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
	str = [str stringByReplacingOccurrencesOfString:@"&#160;" withString:@" "];
	str = [str stringByReplacingOccurrencesOfString:@"&#38;" withString:@"&"];
	str = [str stringByReplacingOccurrencesOfString:@"<br />" withString:@"\n"];
	
	return str;
}

static inline NSData* synatizeResponseData(NSData *data){
	NSString *str = [[[NSString alloc] initWithData:data encoding:4] autorelease];
	if (str && [str length]) {
		NSString *newStr = removeGarbage(str);
		data = [newStr dataUsingEncoding:4];
	}
	return data;
}

static inline NSString* DefaultFloatValue(NSString* str){
	if(str == nil || [str length] < 1){
		str = @"0.0";
	}
	return str;
}

static inline NSString* DefaultStringValue(NSString* str){
	if(str == nil || [str length] < 1){
		str = @"";
	}
	
	return str;
}

static inline BOOL isValidString(id str) {
	
	if ([str isKindOfClass:[NSString class]] && [str length]) {
		return YES;
	}
	
	return NO;
}

static inline BOOL isValidLocation(CLLocation *loc) {
	
	if (loc) {
		if (loc.coordinate.latitude == 0.0f && loc.coordinate.longitude == 0.0f) {
			return NO;
		}else {
			return YES;
		}
	}
	
	return NO;
}

static inline BOOL isValidEmailAddress(NSString *candidate) {
	
	NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:candidate];
}

static inline NSString* getImagePathOfName(NSString* str) {
	
	if(str == nil || [str length] < 1) {
		return @"";
	}else if([DELEGATE iphone4]){
		str = [str stringByAppendingString:@"@2x"];
	}
	
	str = [[NSBundle mainBundle] pathForResource:str ofType:@"png"];
	return str;
}

static inline NSString* getChildAgeFromDate(NSDate *childAge) {
	
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:childAge toDate:[NSDate date] options:0];
	NSString *str_string = @"";
	
	int component = 0;
    if([components year]){
		component = [components year];
		str_string = [NSString stringWithFormat:@"%d", [components year]];
    }
	
	if (![str_string length]) {
		component = [components month];
		str_string = [NSString stringWithFormat:@"%d Mt", [components month]];
		if (component > 1) {
			str_string = [str_string stringByAppendingString:@"s"];
		}
	}
	
	
    [gregorian release];
	return str_string;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Animation

/*
 * The standard duration for transition animations.
 */

#define VXT_TRANSITION_DURATION 0.3
#define VXT_FAST_TRANSITION_DURATION 0.2
#define VXT_FLIP_TRANSITION_DURATION 0.7

///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* VXTPathForBundleResource(NSString* relativePath);

/**
 * Increment the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */

void VXTNetworkRequestStarted();

/**
 * Decrement the number of active network requests.
 *
 * The status bar activity indicator will be spinning while there are active requests.
 */
void VXTNetworkRequestStopped();

/**
 * Gets the current device orientation.
 */
UIDeviceOrientation VXTDeviceOrientation();
UIInterfaceOrientation VXTInterfaceOrientation();
NSString* md5(NSString *str);
NSInteger getAge(NSDate *dateOfBirth); //gets age by putting DOB
NSString* getChildAge(NSString *childAge);
/**
 * Gets the bounds of the screen with device orientation factored in.
 */

CGRect VXTScreenBounds();

CGFloat VXTToolbarHeight();

CGFloat VXTToolbarHeightForOrientation(UIInterfaceOrientation orientation);

CGAffineTransform VXTRotateTransformForOrientation(UIInterfaceOrientation orientation);

BOOL VXTIsSupportedOrientation(UIInterfaceOrientation orientation);

CGRect VXTNavigationFrame();
NSString* VXTPathForBundleResource(NSString* relativePath);
NSString* VXTPathForDocumentsResource(NSString* relativePath);
