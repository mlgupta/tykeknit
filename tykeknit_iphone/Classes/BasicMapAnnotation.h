#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Global.h"

@interface BasicMapAnnotation : NSObject <MKAnnotation> {
	
	UIImage *image;
	CLLocationDegrees _latitude;
	CLLocationDegrees _longitude;
	NSString *_title;
	NSMutableDictionary *dict_data;
	//NSString *userName;
}

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSMutableDictionary *dict_data;
//@property (nonatomic, retain) NSString *userName;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
- (id) initWithDataDictionary : (NSDictionary*)dictData;
- (NSString*) getImagePath;

@end
