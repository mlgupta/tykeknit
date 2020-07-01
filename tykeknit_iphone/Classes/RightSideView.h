//
//  RightSideView.h
//  TykeKnit
//
//  Created by Abhinav Singh on 11/01/11.
//  Copyright 2011 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RightSideViewDelegate

- (void) buttonClickedNamed : (NSString*) name;
//- (BOOL) isWannaHangHighlighted;

@end

@interface RightSideView : UIView {
	id <RightSideViewDelegate>delegate;

	UIButton *btn_wannaHang;
	UIButton *btn_home;
	
	UIButton *btn_playDate1;
	UIButton *btn_playDateSearch;
	UIButton *btn_playDate_send;
	
	UIButton *btn_dashboard_wannaHang;
	UIButton *btn_dashBoard1;
	UIButton *btn_dashBoard2;
	UIButton *btn_dashBoard3;
	UIButton *btn_dashBoard4;

	UIButton *btn_settings_wannaHang;	
	UIButton *btn_settings1;
	UIButton *btn_settings2;
	UIButton *btn_settings3;
	UIButton *btn_settings4;

    UIButton *btn_events1;
	UIButton *btn_events2;

	NSString *loadedView;
	UIImageView *img_back;
	UIButton *btn_currentSelected;
}

@property(nonatomic, assign) id <RightSideViewDelegate>delegate;

/*@property(nonatomic, assign) UIView *vi_playDate;
@property(nonatomic, assign) UIView *vi_settings;
@property(nonatomic, assign) UIView *vi_dashBoard;*/
@property(nonatomic, assign) UIImageView *img_back;

@property(nonatomic, assign) UIButton *btn_currentSelected;
@property(nonatomic, assign) UIButton *btn_wannaHang;
@property(nonatomic, assign) UIButton *btn_home;

@property(nonatomic, assign) UIButton *btn_playDate1;
@property(nonatomic, assign) UIButton *btn_playDateSearch;
@property(nonatomic, assign) UIButton *btn_playDate_send;

@property(nonatomic, assign) UIButton *btn_dashboard_wannaHang;
@property(nonatomic, assign) UIButton *btn_dashBoard1;
@property(nonatomic, assign) UIButton *btn_dashBoard2;
@property(nonatomic, assign) UIButton *btn_dashBoard3;
@property(nonatomic, assign) UIButton *btn_dashBoard4;

@property(nonatomic, assign) UIButton *btn_settings_wannaHang;
@property(nonatomic, assign) UIButton *btn_settings1;
@property(nonatomic, assign) UIButton *btn_settings2;
@property(nonatomic, assign) UIButton *btn_settings3;
@property(nonatomic, assign) UIButton *btn_settings4;

@property(nonatomic, assign) UIButton *btn_events1;
@property(nonatomic, assign) UIButton *btn_events2;

@property(nonatomic, assign) NSString *loadedView;
- (void) hideRightSideView;
- (void) showRightSideView;
- (void) loadView :(NSString *) vi_name;

@end
