//
//  LocationMannager.h
//  SpotWorld
//
//  Created by Abhinav Singh on 27/07/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol LocationMannagerDelegate
- (void) locationUpdated:(CLLocation*)newLocation;
- (void) locationUpdatedFailedWithError:(NSError*)error;
@end

@interface LocationMannager : NSObject <CLLocationManagerDelegate>{
	CLLocationManager *locationManager;
	NSMutableArray *arr_Listners;
	BOOL updatingLocation;
	BOOL alertShown;
	id <LocationMannagerDelegate>delegate;
}

@property(nonatomic, retain) NSMutableArray *arr_Listners;
@property(nonatomic, assign) BOOL updatingLocation;
@property(nonatomic, assign) id <LocationMannagerDelegate>delegate;

- (void) startUpdates;
- (void) addListner : (id) listner;
- (void) removeListner : (id) listner;
- (CLLocation*) getCurrentLocation;
- (void) stopUpdates;

@end
