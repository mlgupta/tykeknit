//
//  VXTTableCellLayer.m
//  SpotWorld
//
//  Created by Abhinav Singh on 07/10/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "VXTTableCellLayer.h"

#define TABLE_CELL_BACKGROUND									{1, 1, 1, 1, 204/255.0, 204/255.0, 204/255.0, 1}		// #FFFFFF and #DDDDDD

@implementation VXTTableCellLayer
@synthesize override = _override;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init { 
    if ((self = [super init])) {
		colorComponents = NSZoneMalloc(NSDefaultMallocZone(), 8*sizeof(CGFloat));
		CGFloat c[8] = TABLE_CELL_BACKGROUND;
		for (int i = 0; i < 8; i++) {
			colorComponents[i] = c[i];
		}
		//		self.backgroundColor = [UAColor clearColor].CGColor;
    }
    return self;
}

- (void) dealloc {
	NSZoneFree(NSDefaultMallocZone(), colorComponents);
	[super dealloc];
}


- (void)display {
	if (_override) {
		self.colors =
		[NSArray arrayWithObjects:
		 (id)[UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:colorComponents[3]].CGColor,
		 (id)[UIColor colorWithRed:colorComponents[4] green:colorComponents[5] blue:colorComponents[6] alpha:colorComponents[7]].CGColor,
		 nil];
	} else {
		self.colors =
		[NSArray arrayWithObjects:
		 (id)[UIColor clearColor].CGColor,
		 (id)[UIColor clearColor].CGColor,
		 nil];
	}
	[super display];
}

- (void)setColorComponents:(CGFloat *)components {
	for (int i = 0; i < 8; i++) {
		colorComponents[i] = components[i];
	}
}

@end
