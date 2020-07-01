//
//  UINavigationBar+BackgroundColor.m
//  TykeKnit
//
//  Created by Ver on 02/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBar+BackgroundColor.h"
#import "Global.h"

@implementation UINavigationBar (BackgroundColor)

- (void)drawRect:(CGRect)rect {

	if (!self.tag || self.tag == 104) {
		UIColor *color =  [UIColor colorWithRed:0.058f green:0.219f blue:0.418f alpha:1.0];
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetFillColor(context, CGColorGetComponents( [color CGColor]));
		CGContextFillRect(context, rect);
	}else {
		[[UIImage imageNamed:@"navigationBarOpaque"] drawInRect:rect];
	}
	
	[super drawRect:rect];	
	
}
@end
