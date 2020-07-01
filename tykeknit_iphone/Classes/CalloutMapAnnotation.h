#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CalloutMapAnnotation : NSObject <MKAnnotation> {
	CLLocationDegrees _latitude;
	CLLocationDegrees _longitude;
	NSMutableDictionary *dict_data;
	NSString *userName;
//	id delegate;
}

@property (nonatomic, retain) NSMutableDictionary *dict_data;
@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic, retain) NSString *userName;
//@property (nonatomic, retain) id delegate;

- (id) initWithDataDictionary : (NSDictionary*)dictData;

@end
