//
//  LocationMannager.m
//  LocallyInApp
//
//  Created by Abhinav Singh on 27/07/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "LocationMannager.h"
#import "Global.h"
#import "Messages.h"

@implementation LocationMannager
@synthesize arr_Listners, updatingLocation,delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		self.arr_Listners = [[NSMutableArray alloc] init];
		self.updatingLocation = YES;
	}
	return self;
}

- (CLLocation*) getCurrentLocation {
	
	if (!isValidLocation(locationManager.location)) {
		return nil;
	}

	return locationManager.location;
}

- (void) startUpdates {
	
	if (!locationManager) {
		
		locationManager.delegate = nil;
		[locationManager release];
		locationManager = nil;
	}

	alertShown = NO;
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	
//	locationManager.purpose = @"If you \"Don't Allow\", we'll use your Zipcode as your location.";
	[locationManager startUpdatingLocation];
}

- (void) addListner : (id) listner {
	[self.arr_Listners addObject:listner];
}

- (void) removeListner : (id) listner {
	[self.arr_Listners removeObject:listner];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{

	if (!newLocation) 
		return;
	
	@synchronized(self) {
		self.updatingLocation = YES;
		for (id listner in self.arr_Listners) {
			if ([listner respondsToSelector:@selector(locationUpdated:)]) {
				[listner performSelectorOnMainThread:@selector(locationUpdated:) withObject:newLocation waitUntilDone:NO];
			}
		}
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	
	if ([error code] == kCLErrorDenied || [error code] == kCLErrorLocationUnknown) {
		
		self.updatingLocation = NO;
		[manager stopUpdatingLocation];
		if(!alertShown){
			if (!self.updatingLocation) {
				NSString *strMessage = @"";
				if ([error code] == kCLErrorDenied) {
					strMessage = TITLE_ERROR_5;
					UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:strMessage delegate:self 
														  cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[alert show];
					[alert release];
					
				}else {
//					strMessage = MSG_ERROR_VALID_LOCATION1;
				}
				
				alertShown = YES;
				self.updatingLocation = YES;
			}
		}

		for (id listner in self.arr_Listners) {
			if ([listner respondsToSelector:@selector(locationUpdatedFailedWithError:)]) {
				[listner performSelectorOnMainThread:@selector(locationUpdatedFailedWithError:) withObject:error waitUntilDone:NO];
			}
		}
	}
}

- (void) stopUpdates {
	[locationManager stopUpdatingLocation];
}

- (void)dealloc {
	
	[locationManager release];
	locationManager = nil;
	[self.arr_Listners removeAllObjects];
	[self.arr_Listners release];
    [super dealloc];
}

@end