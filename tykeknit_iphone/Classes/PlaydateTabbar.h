//
//  PlaydateTabbar.h
//  TykeKnit
//
//  Created by Abhinav Singh on 11/01/11.
//  Copyright 2011 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PlaydateTabbarDelegate 

- (void) buttonSelectedOfName : (NSString*) name;

@end


@interface PlaydateTabbar : UIView {
	UIButton *btn_degree;
	UIButton *btn_gender;
	UIButton *btn_Age;
	
	UIImageView *img_selectedBtn;
	id <PlaydateTabbarDelegate> delegate;
}

@property(nonatomic, assign) id <PlaydateTabbarDelegate> delegate;
@property(nonatomic, assign) UIButton *btn_degree;
@property(nonatomic, assign) UIButton *btn_gender;
@property(nonatomic, assign) UIButton *btn_Age;

@property(nonatomic, assign) UIImageView *img_selectedBtn;
- (void) selectionCompleted : (NSString *)name;

@end
