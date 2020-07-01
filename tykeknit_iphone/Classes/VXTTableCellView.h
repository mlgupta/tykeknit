//
//  VXTTableCellView.h
//  TykeKnit
//
//  Created by Abhinav Singh on 30/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
	CustomTableViewCellStyleNone = 0,
	CustomTableViewCellStyleHorizontalLine,
	CustomTableViewCellStyleVerticalLine,
} CustomTableViewCellStyle;

@interface VXTTableCellView : UIView {
	CustomTableViewCellStyle cellStyle;
	CGPoint startPoint;
}

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CustomTableViewCellStyle cellStyle;

@end