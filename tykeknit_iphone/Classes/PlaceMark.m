//
//  PlaceMark.m
//
//  LocallyInApp
//
//  Created by Abhinav Singh on 23/08/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//


#import "PlaceMark.h"
#import "Global.h"

@implementation PlaceMark
@synthesize coordinate, dict_venueInfo;

- (NSString *)subtitle{
	
//	CLLocation *venueLoc = [[[CLLocation alloc] initWithLatitude:[[self.dict_venueInfo objectForKey:@"Latitude"] doubleValue] longitude:[[self.dict_venueInfo objectForKey:@"Longitude"] doubleValue]] autorelease];
	return @"TODO";
}

- (NSString *)title{
	return @"TODO";//DefaultStringValue([self.dict_venueInfo objectForKey:@"Name"]);
}

- (id)initWithDictionary:(NSDictionary*) dict{
	
	self.dict_venueInfo = dict;
	CLLocationCoordinate2D currCoord;
	currCoord.latitude = [[self.dict_venueInfo objectForKey:@"Latitude"] doubleValue];
	currCoord.longitude = [[self.dict_venueInfo objectForKey:@"Longitude"] doubleValue];
	coordinate = currCoord;
	
	return self;
}

- (void)dealloc {
	[self.dict_venueInfo release];
    [super dealloc];
}


@end
