//
//  VXTTableCellView.m
//  TykeKnit
//
//  Created by Abhinav Singh on 30/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "VXTTableCellView.h"
#import <QuartzCore/QuartzCore.h>

@implementation VXTTableCellView
@synthesize startPoint, cellStyle;

- (void)drawRect:(CGRect)rect {
	if (self.cellStyle != CustomTableViewCellStyleNone) {
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSetRGBStrokeColor(ctx, 0.5, 0.5, 0.5, 1);
		
		if (self.cellStyle == CustomTableViewCellStyleHorizontalLine) {
			CGContextMoveToPoint(ctx, self.startPoint.x, self.startPoint.y);
			CGContextAddLineToPoint( ctx, self.frame.size.width ,self.startPoint.y);
		}else if(self.cellStyle == CustomTableViewCellStyleVerticalLine) {
			CGContextMoveToPoint(ctx, self.startPoint.x, 0);
			CGContextAddLineToPoint( ctx, self.startPoint.x,self.frame.size.height+2);
		}
		
		CGContextStrokePath(ctx);
	}	
}

@end
