//
//  BaseViewController.h
//  TykeKnit
//
//  Created by Abhinav Singh on 30/11/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseView.h"
#import <QuartzCore/QuartzCore.h>

@interface BaseViewController : UIViewController {
	BaseView *vi_main;
	BOOL showingHangView;
	UIImage *prevContImage;
	UIImageView *vi_rings;
	UIViewController *vi_rootViewController;
	
}
//- (void) popWannaHang;
//- (void) pushWannaHang;
- (void) pushingViewController : (UIImage*)imag;
- (void) popToViewController : (UIViewController *)viewController;
- (void) popViewController;
- (UIImage*) captureScreen; 
- (void) BringFrontSubViews;

@property(nonatomic, retain) IBOutlet BaseView *vi_main;
@property(nonatomic, retain) UIViewController *vi_rootViewController;

@property(nonatomic, retain) UIImage *prevContImage;
@end
