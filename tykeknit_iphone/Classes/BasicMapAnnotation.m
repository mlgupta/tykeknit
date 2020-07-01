#import "BasicMapAnnotation.h"

@interface BasicMapAnnotation()

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;

@end

@implementation BasicMapAnnotation

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize title = _title;
@synthesize dict_data, image;


- (NSString*) getImagePath {

	NSString *strImage = nil;
	if ([[self.dict_data objectForKey:@"DegreeCode"] isEqualToString:@"2"]) {
		strImage = getImagePathOfName(@"mapPin_OutOfKnit");
	}else if ([[self.dict_data objectForKey:@"DegreeCode"] isEqualToString:@"3"]) {
		strImage = getImagePathOfName(@"mapPin_OutOfKnit");
	}else if ([[self.dict_data objectForKey:@"DegreeCode"] isEqualToString:@"1"]) {
		strImage = getImagePathOfName(@"mapPin_InKnit");
		for (NSDictionary *dict in [self.dict_data objectForKey:@"Kids"]) {
			if ([[dict objectForKey:@"txtWannaHang"] isEqualToString:@"t"]) {
				strImage = getImagePathOfName(@"mapPin_wannaHang");
				break;
			}
		}
	} else {
		strImage = getImagePathOfName(@"user_location_withoutGlow");
	}
	
	return strImage;
}

- (id) initWithDataDictionary : (NSMutableDictionary*)dictData {
	
	if (self = [super init]) {
		
		self.dict_data = dictData;
		if ([[dictData allKeys] count]) {
			self.latitude = [[dictData objectForKey:@"txtCoordinatesLat"] doubleValue];
			self.longitude = [[dictData objectForKey:@"txtCoordinatesLon"] doubleValue];
			self.title = [NSString stringWithFormat:@"%@ %@",[dictData objectForKey:@"txtParentFname"],[dictData objectForKey:@"txtParentLname"]];
		}else {
		
		}
	}else {

	}

	return self;
}


- (CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = self.latitude;
	coordinate.longitude = self.longitude;
	return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	self.latitude = newCoordinate.latitude;
	self.longitude = newCoordinate.longitude;
}


@end
