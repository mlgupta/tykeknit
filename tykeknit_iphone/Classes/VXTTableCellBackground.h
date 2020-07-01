//
//  VXTTableCellBackground.h
//  SpotWorld
//
//  Created by Abhinav Singh on 07/10/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef enum  {
	VXTTableCellBackgroundViewPositionMiddle = 0,
	VXTTableCellBackgroundViewPositionTop,
    VXTTableCellBackgroundViewPositionBottom,
	VXTTableCellBackgroundViewPositionSingle,
	VXTTableCellBackgroundViewPositionPlain
} VXTTableCellBackgroundViewPosition;


typedef enum  {
	VXTTableCellBackgroundViewStyleNormal = 0,
	VXTTableCellBackgroundViewStyleHighlighted
} VXTTableCellBackgroundViewStyle;


@interface VXTTableCellBackground : UIView {
	VXTTableCellBackgroundViewPosition position;
	VXTTableCellBackgroundViewStyle viewStyle;
	CGFloat colors[8];
}

@property(nonatomic, assign) VXTTableCellBackgroundViewPosition position;
@property(nonatomic, assign) VXTTableCellBackgroundViewStyle viewStyle;

- (void)setColors:(CGFloat[8])comps;

@end