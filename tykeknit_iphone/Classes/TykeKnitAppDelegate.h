//
//  TykeKnitAppDelegate.h
//  TykeKnit
//
//  Created by Abhinit Tiwari on 27/09/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceBookEngine.h"
#import "LocationMannager.h"
#import "RightSideView.h"
#import "HomeViewController.h"
//#import "VXTWindow.h"

@interface TykeKnitAppDelegate : NSObject <UIApplicationDelegate, RightSideViewDelegate,LocationMannagerDelegate,UIAlertViewDelegate> {
	
//    VXTWindow *window;
	UIWindow *window;
	FaceBookEngine *objFaceBook;
	
	RightSideView *vi_sideView;
	
	NSMutableDictionary *dict_userInfo;
	NSMutableDictionary *dict_settings;
	NSMutableArray *arr_kidsList;
	
	UIViewController *vi_wannaHang;
	
	id api_tyke;
	UINavigationController *nav_login;
	
	UINavigationController *nav_dashBoard;
	UINavigationController *nav_Settings;
	UINavigationController *nav_playDate;
	
	UINavigationController *topNavigationController;
	
	UINavigationController *nav_wannaHangBar;
	BOOL iphone4;
	LocationMannager *loc_Manager;
	HomeViewController *home_viewCont;
	NSDate *latestLocationUpdatedBeforeTime;
    
    NSString *apnDeviceID;
}

@property (nonatomic, assign) BOOL iphone4;
@property (nonatomic, retain) RightSideView *vi_sideView;
@property (nonatomic, retain) UINavigationController *nav_dashBoard;
@property (nonatomic, retain) UINavigationController *nav_playDate;
@property (nonatomic, retain) UINavigationController *nav_Settings;
@property (nonatomic, retain) UINavigationController *nav_Events;
@property (nonatomic, retain) UINavigationController *nav_login;
@property (nonatomic, retain) UINavigationController *topNavigationController;
@property (nonatomic, retain) UINavigationController *nav_wannaHangBar;
@property (nonatomic, retain) HomeViewController *home_viewCont;
@property (nonatomic, retain) IBOutlet UIViewController *vi_wannaHang;
@property (nonatomic, retain) NSMutableDictionary *dict_userInfo;
@property (nonatomic, retain) NSMutableArray *arr_kidsList;
//@property (nonatomic, retain) IBOutlet VXTWindow *window;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) NSDate *latestLocationUpdatedBeforeTime;
@property (nonatomic, retain) NSString *apnDeviceID;
@property (nonatomic, retain) NSMutableDictionary *dict_settings;
@property (nonatomic, retain) id api_tyke;

- (BOOL) hasNetworkConnection ;
- (FaceBookEngine*) getFaceBookObj;
- (void) logOutCurrentUser;

- (UIButton*) getBackBarButton;
- (UIButton*) getBackBarButtonWithTitle:(NSString *)Title;
- (UIButton*) getNextBarButton;
- (UIButton*) getDefaultBarButtonWithTitle : (NSString*)str_title;
- (void) homeButtonClicked : (NSString *) name;
- (UIView*)getTykeTitleView;
- (UIView*)getTykeTitleViewWithTitle : (NSString *)title;
- (HomeViewController *)getHomeView;
- (void) drawTabBar;

- (void) addLoadingView : (UIView*)vi_main;
- (void) removeLoadingView : (UIView*)vi_main;
- (void) userLoggedInWithDict : (NSDictionary*)dictRespo;
- (NSMutableDictionary *)getUserDetails;
#pragma mark -
#pragma mark LocationMannager methods

- (void) removeLocationListner : (id) viewCont;
- (void) addLocationListner : (id) viewCont;
- (CLLocation*) getCurrentLocation;
- (CLLocation*) getAcctualDeviceValues;
- (void) showLocationError;
- (void) cannotBeAbleToLogin;
- (void) switchLocationManagerOn : (BOOL) on;

#pragma mark - 
#pragma mark For SideView

- (void) bringSideViewToFront;
- (void) putSideViewToBack;

- (CLLocation*) getCurrentLocation;

- (void) removeApplicationUI;
- (void) removeFromDocDirFileName:(NSString*)name;

@end

