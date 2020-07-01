#import "CalloutMapAnnotation.h"
#import "Global.h"
@interface CalloutMapAnnotation()

@end

@implementation CalloutMapAnnotation

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize dict_data,userName;

- (id) initWithDataDictionary : (NSMutableDictionary*)dictData {
	
	if (self = [super init]) {
		self.dict_data = dictData;
	}
	
	return self;
}

- (void) setDict_data:(NSMutableDictionary *) dictdata {
	
	dict_data = dictdata;
	if (!dict_data) {
		CLLocation *location = [DELEGATE getCurrentLocation];
		if (location) {
			self.latitude = location.coordinate.latitude;
			self.longitude = location.coordinate.longitude;
		}
	}else {
		self.userName = nil;
		self.latitude = [[dict_data objectForKey:@"txtCoordinatesLat"] doubleValue];
		self.longitude = [[dict_data objectForKey:@"txtCoordinatesLon"] doubleValue];
	}
}

- (void) setUserName : (NSString*)user {
	
//	if(self.userName){
//		self.dict_data = nil;
//		[self.userName release];
//	}
//	
//	userName = [user retain];
	
	
	userName = user;
	if(userName)
		self.dict_data = nil;
}

- (CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = self.latitude;
	coordinate.longitude = self.longitude;
	return coordinate;
}

@end
