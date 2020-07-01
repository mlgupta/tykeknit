//
//  VXTTableCellBackground.m
//  SpotWorld
//
//  Created by Abhinav Singh on 07/10/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "VXTTableCellBackground.h"
#import "VXTTableCellLayer.h"
#import <QuartzCore/QuartzCore.h>

#define kDefaultMargin											10
#define TABLE_CELL_BACKGROUND									{1, 1, 1, 1, 255/255.0, 255/255.0, 255/255.0, 1}
#define TABLE_CELL_HIGHLIGHTED_BACKGROUND						{0.8, 0.8, 0.8, 1, 204/255.0, 204/255.0, 204/255.0, 1}

@implementation VXTTableCellBackground
@synthesize position, viewStyle;

+ (Class)layerClass {
	return [VXTTableCellLayer class];
}

- (void)updateLayer {
	VXTTableCellLayer* layer = (VXTTableCellLayer*)self.layer;
	[layer setColorComponents:colors];
	layer.override = (self.position == VXTTableCellBackgroundViewPositionPlain);
	[layer setNeedsDisplay];
}


- (void)setColors:(CGFloat[8])comps {
	for (int i = 0; i < 8; i++) {
		colors[i] = comps[i];
	}
}

- (BOOL)isOpaque {
    return YES;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self != nil) {
		CGFloat comps[8] = TABLE_CELL_BACKGROUND;
		[self setColors:comps];
	}
	return self;
}

-(void)drawRect:(CGRect)aRect {
	[super drawRect:aRect];

	if (position == VXTTableCellBackgroundViewPositionPlain) {
		return;
	}
	
	CGContextRef c = UIGraphicsGetCurrentContext();	
	int lineWidth = 1;
	
	CGRect rect = [self bounds];
	rect.size.width -= lineWidth;
	rect.size.height -= lineWidth;
	rect.origin.x += lineWidth / 2.0;
	rect.origin.y += lineWidth / 2.0;
	
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
	miny -= 1;
	
	CGFloat locations[2] = { 0.0, 1.0 };	
	CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef myGradient = nil;
	
	CGContextSetStrokeColorWithColor(c, [UIColor clearColor].CGColor);
    CGContextSetLineWidth(c, lineWidth);
	CGContextSetAllowsAntialiasing(c, YES);
	CGContextSetShouldAntialias(c, YES);
	
    if (position == VXTTableCellBackgroundViewPositionTop) {
		miny += 1;
		
		CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, minx, maxy);
        CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, kDefaultMargin);
        CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, maxy, kDefaultMargin);
        CGPathAddLineToPoint(path, NULL, maxx, maxy);
		CGPathAddLineToPoint(path, NULL, minx, maxy);
		CGPathCloseSubpath(path);
		
		CGContextSaveGState(c);
		CGContextAddPath(c, path);
		CGContextClip(c);
		
		myGradient = CGGradientCreateWithColorComponents(myColorspace, colors, locations, 2);
		CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
		
		CGContextAddPath(c, path);
		CGPathRelease(path);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
    } else if (position == VXTTableCellBackgroundViewPositionBottom) {
		
		CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, minx, miny);
        CGPathAddArcToPoint(path, NULL, minx, maxy, midx, maxy, kDefaultMargin);
        CGPathAddArcToPoint(path, NULL, maxx, maxy, maxx, miny, kDefaultMargin);
        CGPathAddLineToPoint(path, NULL, maxx, miny);
        CGPathAddLineToPoint(path, NULL, minx, miny);
		CGPathCloseSubpath(path);
		
		// Fill and stroke the path
		CGContextSaveGState(c);
		CGContextAddPath(c, path);
		CGContextClip(c);
		
		myGradient = CGGradientCreateWithColorComponents(myColorspace, colors, locations, 2);
		CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
		
		CGContextAddPath(c, path);
		CGPathRelease(path);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
		
    } else if (position == VXTTableCellBackgroundViewPositionMiddle) {
		
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, minx, miny);
		CGPathAddLineToPoint(path, NULL, maxx, miny);
		CGPathAddLineToPoint(path, NULL, maxx, maxy);
		CGPathAddLineToPoint(path, NULL, minx, maxy);
		CGPathAddLineToPoint(path, NULL, minx, miny);
		CGPathCloseSubpath(path);
		
		// Fill and stroke the path
		CGContextSaveGState(c);
		CGContextAddPath(c, path);
		CGContextClip(c);
		
		myGradient = CGGradientCreateWithColorComponents(myColorspace, colors, locations, 2);
		CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
		
		CGContextAddPath(c, path);
		CGPathRelease(path);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
    } else if (position == VXTTableCellBackgroundViewPositionSingle) {
		miny += 1;
		//maxy -= 1; // -1 for the shadow 
		
		CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path, NULL, minx, midy);
        CGPathAddArcToPoint(path, NULL, minx, miny, midx, miny, kDefaultMargin);
        CGPathAddArcToPoint(path, NULL, maxx, miny, maxx, midy, kDefaultMargin);
        CGPathAddArcToPoint(path, NULL, maxx, maxy, midx, maxy, kDefaultMargin);
        CGPathAddArcToPoint(path, NULL, minx, maxy, minx, midy, kDefaultMargin);
		CGPathCloseSubpath(path);
		
		// Shadow
		//		CGContextAddPath(c, path);
		//		CGContextSaveGState(c);
		//		CGContextSetShadow(c, CGSizeMake(0, -1), 1);
		//		CGContextFillPath(c);
		
		// Fill and stroke the path
		CGContextSaveGState(c);
		CGContextAddPath(c, path);
		CGContextClip(c);
		
		
		myGradient = CGGradientCreateWithColorComponents(myColorspace, colors, locations, 2);
		CGContextDrawLinearGradient(c, myGradient, CGPointMake(minx,miny), CGPointMake(minx,maxy), 0);
		
		CGContextAddPath(c, path);
		CGPathRelease(path);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
	}
	CGColorSpaceRelease(myColorspace);
	CGGradientRelease(myGradient);
	return;
}


- (void)setPosition:(VXTTableCellBackgroundViewPosition)newPosition {
	if (position != newPosition) {
		position = newPosition;
		[self updateLayer];
	}
}

- (void)setViewStyle:(VXTTableCellBackgroundViewStyle)newStyle {
	if (viewStyle != newStyle) {
		viewStyle = newStyle;
		if (newStyle == VXTTableCellBackgroundViewStyleHighlighted) {
			CGFloat comps[8] = TABLE_CELL_HIGHLIGHTED_BACKGROUND;
			[self setColors:comps];
		}else {
			CGFloat comps[8] = TABLE_CELL_BACKGROUND;
			[self setColors:comps];
		}

		[self updateLayer];
	}
}

@end
