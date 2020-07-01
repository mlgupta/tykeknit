//
//  VXTTableCellLayer.h
//  SpotWorld
//
//  Created by Abhinav Singh on 07/10/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>

@class VXTTableCellBackground;

@interface VXTTableCellLayer : CAGradientLayer {
	CGFloat		*colorComponents;
	BOOL		_override;
}

@property(nonatomic,assign) BOOL override;

- (void)setColorComponents:(CGFloat *)components;

@end