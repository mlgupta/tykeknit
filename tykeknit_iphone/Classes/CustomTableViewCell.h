//
//  CustomTableViewCell.h
//  TykeKnit
//
//  Created by Abhinav Singh on 30/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VXTTableCellView.h"

@interface CustomTableViewCell : UITableViewCell {
	VXTTableCellView *content;
}

@property(nonatomic, retain) VXTTableCellView *content;

@end
