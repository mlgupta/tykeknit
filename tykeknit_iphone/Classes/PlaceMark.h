//
//  PlaceMark.h
//
//  LocallyInApp
//
//  Created by Abhinav Singh on 23/08/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface PlaceMark : UIView<MKAnnotation> {
	CLLocationCoordinate2D coordinate;
	NSDictionary *dict_venueInfo;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSDictionary *dict_venueInfo;

- (id)initWithDictionary:(NSDictionary*) dict;
- (NSString *)subtitle;
- (NSString *)title;


@end
