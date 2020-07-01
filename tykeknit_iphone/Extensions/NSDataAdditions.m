//
//  NSDataAdditions.m
//  HeroesWorld
//
//  Created by Abhinav Singh on 31/01/11.
//  Copyright 2011 Vercingetorix Technologies. All rights reserved.
//

#import "NSDataAdditions.h"


@implementation NSData(VxtAddition)

- (NSString*)stringValue {

	NSString *strValue = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
	return [strValue autorelease];
}

@end
