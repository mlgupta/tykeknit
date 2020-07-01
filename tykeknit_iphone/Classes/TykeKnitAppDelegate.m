//
//  TykeKnitAppDelegate.m
//  TykeKnit
//
//  Created by Abhinit Tiwari on 27/09/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TykeKnitAppDelegate.h"
#include <SystemConfiguration/SCNetworkReachability.h>
#import "UserRegStepTwo.h"
#import "FaceBookEngine.h"
#import "userAuthentication.h"
#import "LoginViewController.h"
#import "Global.h"
#import "TykeKnitLoginVC.h"
#import "vxtLoadingView.h"
#import "DashboardViewController.h"
#import "AccountInfoViewController.h"
#import "EventsViewController.h"
#import "JSON.h"
#import "PlayDateViewController.h"
#import "WannaHangViewController.h"
#import "RightSideView.h"
#import "HomeViewController.h"
#import "Messages.h"
#import "BaseViewController.h"

@implementation TykeKnitAppDelegate

@synthesize window, vi_sideView, dict_userInfo,arr_kidsList,vi_wannaHang,nav_wannaHangBar,topNavigationController,dict_settings;
@synthesize nav_login, iphone4, nav_Settings, nav_Events, nav_dashBoard, nav_playDate,home_viewCont,latestLocationUpdatedBeforeTime,apnDeviceID;
@synthesize api_tyke;

#pragma mark -
#pragma mark Application lifecycle

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame {

//	[UIView beginAnimations:@"windowAnimation" context:NULL];
//	if ([[UIApplication sharedApplication] statusBarFrame].size.height == 20) {
//		window.frame = CGRectMake(0, 0, window.frame.size.width, window.frame.size.height);		
//        
//	} else {
//		window.frame = CGRectMake(0, 20, window.frame.size.width, window.frame.size.height);
//    }
//	[UIView commitAnimations];
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
}

- (void) buttonClickedNamed : (NSString*) name {
	
	if ([name isEqualToString:@"DashBoard"]) {
		if (self.nav_dashBoard.view) {
			[self.window insertSubview:self.nav_dashBoard.view belowSubview:self.vi_sideView];
			self.topNavigationController = self.nav_dashBoard;
		}
		self.vi_sideView.delegate = (PlayDateViewController *)self.nav_dashBoard.topViewController;
	}else if ([name isEqualToString:@"PlayDate"]) {
		if (self.nav_playDate.view) {
			[self.window insertSubview:self.nav_playDate.view belowSubview:self.vi_sideView];
			self.topNavigationController = self.nav_playDate;
		}
		self.vi_sideView.delegate = (DashboardViewController *) self.nav_playDate.topViewController;
	}else if ([name isEqualToString:@"Settings"]) {
		if (self.nav_Settings.view) {
			[self.window insertSubview:self.nav_Settings.view belowSubview:self.vi_sideView];
			self.topNavigationController = self.nav_Settings;
		}
		self.vi_sideView.delegate =(AccountInfoViewController *) self.nav_Settings.topViewController;

	}else if ([name isEqualToString:@"Events"]) {
		if (self.nav_Events.view) {
			[self.window insertSubview:self.nav_Events.view belowSubview:self.vi_sideView];
			self.topNavigationController = self.nav_Events;
		}
		self.vi_sideView.delegate =(EventsViewController *) self.nav_Events.topViewController;
/*
	}else if ([name isEqualToString:@"WannaHang"]) {
		UIViewController *viewCont = self.topNavigationController.topViewController;
		if ([viewCont isKindOfClass:[PlayDateViewController class]]) {
			[(PlayDateViewController*)viewCont removeReloadButton];
		}
		
		if (!vi_wannaHang) {
			vi_wannaHang = [[WannaHangViewController alloc] initWithNibName:@"WannaHangViewController" bundle:nil];
			[self.topNavigationController pushViewController:vi_wannaHang animated:NO];
		}
		
		if ([self.topNavigationController.viewControllers containsObject:vi_wannaHang]) {
			[(BaseViewController *)self.topNavigationController.topViewController popWannaHang];
		}else {
			[(BaseViewController *)self.topNavigationController.topViewController pushWannaHang];
			[self.topNavigationController pushViewController:vi_wannaHang animated:NO];
		}
*/ 
	} 
}


- (BOOL) isWannaHangHighlighted {
	
	BOOL RET = NO;
	if([nav_wannaHangBar.view superview]) {
		RET = YES;
	}
	
	return RET;
}


- (void) getMapDetailsResponse : (NSData *) data {
//	NSDictionary *response = [[data stringValue] JSONValue];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL success = [fileManager fileExistsAtPath:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"]];
	if(!success) {
		[fileManager copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"] 
							 toPath:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] error:nil];
	}
	
	api_tyke = (TykeKnitApi*)[[TykeKnitApi alloc] init];
	[api_tyke setDelegate:self];
	
	[self switchLocationManagerOn:YES];

	self.dict_settings = [[NSMutableDictionary alloc]init];
	self.dict_settings = [NSMutableDictionary dictionaryWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"]];
	
	if([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.2f){
		UIScreen* screen = [UIScreen mainScreen];
		self.iphone4 = (screen.currentMode.size.width == 640.0f);
	}else{
		self.iphone4 = NO;
	}
	
	self.dict_userInfo = [NSMutableDictionary dictionaryWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"userInfo.plist"]];
	if (!self.dict_userInfo) {
		self.dict_userInfo = [[NSMutableDictionary alloc] init];
	}
	
	if ([self.dict_userInfo objectForKey:@"user_name"] && [self.dict_userInfo objectForKey:@"password"]) {
		TykeKnitApi *api = (TykeKnitApi*)api_tyke;
		[api userLogin:[self.dict_userInfo objectForKey:@"user_name"] txtPassword:[self.dict_userInfo objectForKey:@"password"] txtDToken:apnDeviceID];
		[self addLoadingView:nil];
	}else {
		LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
		self.nav_login = [[UINavigationController alloc] initWithRootViewController:login];
//		self.nav_login.navigationBar.tintColor = [UIColor colorWithRed:0.623 green:0.850 blue:0.996 alpha:1];
		self.nav_login.navigationBar.tintColor = [UIColor colorWithRed:0.058f green:0.219f blue:0.418f alpha:1.0];
        
		[login release];
		[window addSubview:self.nav_login.view];
		
		self.topNavigationController = self.nav_login;
	}
	
//	((TykeKnitApi*)api_tyke).delegate = self;
//	[api_tyke getUserSettings];
	
	[window makeKeyAndVisible];
    
    // We want to receive push notifications
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	
	return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken 
{
    self.apnDeviceID = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<" withString:@""]
                                                   stringByReplacingOccurrencesOfString:@">" withString:@""]
                                                   stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSLog(@"My Token is: %@", self.apnDeviceID);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Failed to get Token: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo 
{
    for (id key in userInfo) {
        NSLog(@"key: %@, value: %@", key, [userInfo objectForKey:key]);
    }
}

- (void) switchLocationManagerOn : (BOOL) on {
	 
	if (on) {
		
		loc_Manager = [[LocationMannager alloc] init];
		loc_Manager.delegate = self;
		
		[loc_Manager performSelectorOnMainThread:@selector(startUpdates) withObject:nil waitUntilDone:NO];
		self.latestLocationUpdatedBeforeTime = [NSDate date];
	}else {
		[loc_Manager stopUpdates];
		[loc_Manager release];
		loc_Manager = nil;
	}
}

- (void) bringSideViewToFront {
	
	[self.window bringSubviewToFront:self.vi_sideView];
}

- (void) putSideViewToBack {
	
	[self.window sendSubviewToBack:self.vi_sideView];
}

- (void) userLoggedInWithDict : (NSDictionary*)dictRespo {
	
	if ([dictRespo objectForKey:@"user_name"]) {
		[self.dict_userInfo setObject:[dictRespo objectForKey:@"user_name"] forKey:@"user_name"];
	}
	
	if ([dictRespo objectForKey:@"password"]) {
		[self.dict_userInfo setObject:[dictRespo objectForKey:@"password"] forKey:@"password"];
	}
	
	if ([dictRespo objectForKey:@"response"]) {
		[self.dict_userInfo setObject:[dictRespo objectForKey:@"response"] forKey:@"response"];
	}
	
	//[self.dict_userInfo setObject:[dictRespo objectForKey:@"sessionID"] forKey:@"sessionID"];
	[self.dict_userInfo writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userInfo.plist"] atomically:NO];
	
	[self drawTabBar];
}

- (void) removeFromDocDirFileName:(NSString*)name {
	
	NSString *strPath = [DOC_DIR stringByAppendingPathComponent:name];
	NSFileManager *fileManeger = [NSFileManager defaultManager];
	if([fileManeger fileExistsAtPath:strPath]){
		[fileManeger removeItemAtPath:strPath error:nil];
	}
}

- (void) removeApplicationUI {
	
	NSArray *arr = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
	for (NSHTTPCookie *cookie in arr) {
		[[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
	}
	[self.dict_userInfo removeAllObjects];
	[self.dict_userInfo writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userInfo.plist"] atomically:NO];
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"]];
	[dict removeAllObjects];
	[dict writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"] atomically:NO];

	
//	[self.nav_dashBoard.view removeFromSuperview];
//	[self.nav_dashBoard release];
//	self.nav_dashBoard = nil;
//
//	[self.nav_wannaHangBar.view removeFromSuperview];
////	[self.nav_wannaHangBar release];
//	self.nav_wannaHangBar = nil;
//	
//	[self.nav_playDate.view removeFromSuperview];
//	[self.nav_playDate release];
//	self.nav_playDate = nil;
//	
	[self.vi_sideView removeFromSuperview];
	[self.vi_sideView release];
	self.vi_sideView  = nil;
//	
//	[self.nav_Settings.view removeFromSuperview];
//	[self.nav_Settings release];
//	self.nav_Settings = nil;
	

	[self.topNavigationController.view removeFromSuperview];
	
	LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
	self.nav_login = [[UINavigationController alloc] initWithRootViewController:login];
//	self.nav_login.navigationBar.tintColor = [UIColor colorWithRed:0.623 green:0.850 blue:0.996 alpha:1];
	self.nav_login.navigationBar.tintColor = [UIColor colorWithRed:0.058f green:0.219f blue:0.418f alpha:1.0];;
	[login release];
	[window addSubview:self.nav_login.view];
	
	self.topNavigationController = self.nav_login;
	[self.dict_userInfo removeAllObjects];
	[self.arr_kidsList removeAllObjects];
	[self bringSideViewToFront];
	
	[vi_sideView setUserInteractionEnabled:NO];
}


- (void) logOutCurrentUser {
	
//	[DELEGATE addLoadingView:nil];
	[self removeApplicationUI];
	[api_tyke userLogOut:[[self.dict_userInfo objectForKey:@"response"] objectForKey:@"sessionID"]];
}

- (void) logOutResponce : (NSData*)data {
	
//	[self removeLoadingView:nil];
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		
	}
}

- (BOOL) hasNetworkConnection {
	
	SCNetworkReachabilityRef reach = SCNetworkReachabilityCreateWithName(kCFAllocatorSystemDefault, "google.com");
	SCNetworkReachabilityFlags flags;
	SCNetworkReachabilityGetFlags(reach, &flags);
	BOOL ret = (kSCNetworkReachabilityFlagsReachable & flags) || (kSCNetworkReachabilityFlagsConnectionRequired & flags);
	CFRelease(reach);
	reach = nil;
	return ret;
}

- (void) homeButtonClicked : (NSString *) name {
	
	if ([[self.window subviews] containsObject:self.nav_wannaHangBar]) {
		//		[self.vi_wannaHang removeFromSuperview];
		[self.nav_wannaHangBar.view removeFromSuperview];
	}
	if ([name isEqualToString:@"DashBoard"]) {
		if (![topNavigationController isEqual:self.nav_dashBoard]) {
			[topNavigationController.view removeFromSuperview];
			
			DashboardViewController *dashboard = [[DashboardViewController alloc] initWithNibName:@"DashboardView" bundle:nil];
			self.nav_dashBoard = [[UINavigationController alloc] initWithRootViewController:dashboard];
//			self.nav_dashBoard.navigationBar.tintColor = [UIColor colorWithRed:0.623 green:0.850 blue:0.996 alpha:1];
			self.nav_dashBoard.navigationBar.tintColor = [UIColor colorWithRed:0.058f green:0.219f blue:0.418f alpha:1.0];
			[dashboard release];
			[self.window addSubview:self.nav_dashBoard.view];
		}
		[self.vi_sideView loadView:@"DashBoard"];
		[self.window insertSubview:self.nav_dashBoard.view belowSubview:self.vi_sideView];
		topNavigationController = self.nav_dashBoard;
		
	}else if ([name isEqualToString:@"PlayDate"]) {
		if (![topNavigationController isEqual:self.nav_playDate]) {
			[topNavigationController.view removeFromSuperview];
		}
		if (self.nav_playDate.view) {
			[self.vi_sideView loadView:@"playDate"];
			[self.window insertSubview:self.nav_playDate.view belowSubview:self.vi_sideView];
			topNavigationController = self.nav_playDate;
			
			UIViewController *viewCont = self.topNavigationController.topViewController;
			if (!vi_wannaHang) {
				vi_wannaHang = [[WannaHangViewController alloc] initWithNibName:@"WannaHangViewController" bundle:nil];
			}
            else {
                [vi_wannaHang release];
				vi_wannaHang = [[WannaHangViewController alloc] initWithNibName:@"WannaHangViewController" bundle:nil];
            }
            
			UIView *mainView = [(BaseViewController*)viewCont vi_main];
			[mainView endEditing:YES];
			[mainView setBackgroundColor:[UIColor grayColor]];
			
			if(![[self.topNavigationController viewControllers] containsObject:vi_wannaHang]) {
				[self.topNavigationController pushViewController:vi_wannaHang animated:NO];
			}
		}
/* 
	}else if ([name isEqualToString:@"PlayDate"]) {
		if (![topNavigationController isEqual:self.nav_playDate]) {
			[topNavigationController.view removeFromSuperview];

            WannaHangViewController *wannaHang = [[WannaHangViewController alloc] initWithNibName:@"WannaHangViewController" bundle:nil];
            self.nav_playDate = [[UINavigationController alloc] initWithRootViewController:wannaHang];
            self.nav_playDate.navigationBar.tintColor = [UIColor colorWithRed:0.623 green:0.850 blue:0.996 alpha:1];
            [self.nav_playDate pushViewController:wannaHang animated:NO];
            [wannaHang release];
            [self.window addSubview:self.nav_playDate.view];
		}
        [self.vi_sideView loadView:@"playDate"];
        [self.window insertSubview:self.nav_playDate.view belowSubview:self.vi_sideView];
        topNavigationController = self.nav_playDate;
*/
    }else if ([name isEqualToString:@"Settings"]) {
		if (![topNavigationController isEqual:self.nav_Settings]) {
			[topNavigationController.view removeFromSuperview];
			
			AccountInfoViewController *settings = [[AccountInfoViewController alloc] initWithNibName:@"AccountInfoView" bundle:nil];
			self.nav_Settings = [[UINavigationController alloc] initWithRootViewController:settings];
//			self.nav_Settings.navigationBar.tintColor = [UIColor colorWithRed:0.623 green:0.850 blue:0.996 alpha:1];
			self.nav_Settings.navigationBar.tintColor = [UIColor colorWithRed:0.058f green:0.219f blue:0.418f alpha:1.0];
            
			[settings release];
			[self.window addSubview:self.nav_Settings.view];
		}
		[self.vi_sideView loadView:@"Settings"];
		[self.window insertSubview:self.nav_Settings.view belowSubview:self.vi_sideView];
		topNavigationController = self.nav_Settings;
	}else if ([name isEqualToString:@"Events"]) {
		if (![topNavigationController isEqual:self.nav_Events]) {
			[topNavigationController.view removeFromSuperview];
			
			EventsViewController *events = [[EventsViewController alloc] initWithNibName:@"EventsView" bundle:nil];
			self.nav_Events = [[UINavigationController alloc] initWithRootViewController:events];
//			self.nav_Events.navigationBar.tintColor = [UIColor colorWithRed:0.623 green:0.850 blue:0.996 alpha:1];
			self.nav_Events.navigationBar.tintColor = [UIColor colorWithRed:0.058f green:0.219f blue:0.418f alpha:1.0];;
			[events release];
			[self.window addSubview:self.nav_Events.view];
		}
		[self.vi_sideView loadView:@"Events"];
		[self.window insertSubview:self.nav_Events.view belowSubview:self.vi_sideView];
		topNavigationController = self.nav_Events;
	}
	
	self.vi_sideView.delegate = [[topNavigationController viewControllers] objectAtIndex:0];
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


- (HomeViewController *)getHomeView {
	return self.home_viewCont;
}
- (UIView*)getTykeTitleViewWithTitle : (NSString *)title {
	
	UILabel *lbl_title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 24)];
	lbl_title.text = title;
	lbl_title.textColor = [UIColor whiteColor];
	lbl_title.textAlignment = UITextAlignmentCenter;
	lbl_title.font = [UIFont boldSystemFontOfSize:18];
	lbl_title.backgroundColor = [UIColor clearColor];
	
	return [lbl_title autorelease];
}


- (UIView*)getTykeTitleView {
	
	UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 134, 34)];
	imgView.contentMode = UIViewContentModeScaleAspectFit;
	imgView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tykelogo" ofType:@"png"]];
	
	return [imgView autorelease];
}

- (UIButton*) getDefaultBarButtonWithTitle : (NSString*)str_title {
	
	UIButton *btn_cust = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn_cust setTitle:str_title forState:UIControlStateNormal];
	[[btn_cust titleLabel] setShadowColor:[UIColor darkGrayColor]];
	[[btn_cust titleLabel] setShadowOffset:CGSizeMake(0, -1)];
	[[btn_cust titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
//	[[btn_cust titleLabel] setTextColor:[UIColor whiteColor]];
	[btn_cust setFrame:CGRectMake(0, 0, 60, 29)];
	[btn_cust setBackgroundColor:[UIColor colorWithRed:0.047 green:0.176 blue:0.461 alpha:1.0]];
//	[btn_cust setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"default_barButton")] forState:UIControlStateNormal];
	[btn_cust setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_DefaultBarButton")] forState:UIControlStateNormal];
	[btn_cust setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_DefaultBarButtonHighlighted")] forState:UIControlStateHighlighted];
	
	return btn_cust;
}

- (UIButton*) getBackBarButton {
	
	UIButton *btn_cust = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn_cust setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
	[btn_cust setTitle:@"Back" forState:UIControlStateNormal];
	[[btn_cust titleLabel] setShadowColor:[UIColor darkGrayColor]];
	[[btn_cust titleLabel] setShadowOffset:CGSizeMake(0, -1)];
	[[btn_cust titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
	[btn_cust setFrame:CGRectMake(0, 0, 50, 29)];
//	[btn_cust setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"default_backBarButton")] forState:UIControlStateNormal];
//	[btn_cust setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_DefaultBackBarButton")] forState:UIControlStateNormal];
	[btn_cust setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_back")] forState:UIControlStateNormal];
	[btn_cust setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"backbtn_highlighted")] forState:UIControlStateHighlighted];
	
	return btn_cust;
}

- (UIButton*) getBackBarButtonWithTitle:(NSString *)Title {
	
	UIButton *btn_cust = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn_cust setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
	[btn_cust setTitle:Title forState:UIControlStateNormal];
	[[btn_cust titleLabel] setFont:[UIFont boldSystemFontOfSize:12]];
	[btn_cust setFrame:CGRectMake(0, 0, 65, 35)];
	[btn_cust setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_DefaultBackBarButton")] forState:UIControlStateNormal];
	
	return btn_cust;
}

- (UIButton*) getNextBarButton {
	
	UIButton *btn_cust = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn_cust setTitleEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 0)];
	[btn_cust setTitle:@"Next" forState:UIControlStateNormal];
	[[btn_cust titleLabel] setFont:[UIFont boldSystemFontOfSize:12]];
	[btn_cust setFrame:CGRectMake(0, 0, 65, 35)];
	[btn_cust setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_BarNext")] forState:UIControlStateNormal];
	
	return btn_cust;
}


- (void) drawTabBar {

//    UINavigationController *dummyNavController = [[UINavigationController alloc] init];
//    dummyNavController.view.backgroundColor = [UIColor blackColor];
//    dummyNavController.navigationBarHidden = YES;
//    [self.window addSubview:dummyNavController.view];

	self.vi_sideView = [[RightSideView alloc] initWithFrame:CGRectMake(280, 83, 42, 418)];
	vi_sideView.delegate = self;
	[self.window setBackgroundColor:[UIColor blackColor]];
	[self.window addSubview:self.vi_sideView];

	if ([self.topNavigationController.view superview]) {
		[self.topNavigationController.view removeFromSuperview];
	}
   
	PlayDateViewController *playDate = [[PlayDateViewController alloc] initWithNibName:@"PlayDateView" bundle:nil];
	self.nav_playDate = [[UINavigationController alloc] initWithRootViewController:playDate];
	self.nav_playDate.navigationBar.tintColor = [UIColor colorWithRed:0.058f green:0.219f blue:0.418f alpha:1.0];
	self.nav_playDate.view.tag = 2001;
	[playDate release];
	[self.window addSubview:self.nav_playDate.view];
	
	self.topNavigationController = self.nav_playDate;

    [self.vi_sideView setUserInteractionEnabled:YES];
	
	[self bringSideViewToFront];
	
	home_viewCont = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
	UINavigationController *nav_home = [[UINavigationController alloc]initWithRootViewController:home_viewCont];
    nav_home.navigationBar.tintColor = [UIColor colorWithRed:0.058f green:0.219f blue:0.418f alpha:1.0];
	[self.window addSubview:nav_home.view];
	
//	home_viewCont = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
//	[self.topNavigationController.topViewController presentModalViewController:home_viewCont animated:YES];
//	[DELEGATE putSideViewToBack];
}

- (NSMutableDictionary *)getUserDetails {
	NSMutableDictionary *userDetails = [NSMutableDictionary dictionaryWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"]];
	return userDetails;
}

#pragma mark - 
#pragma Settings Delegate methods

- (void) updateSettingsResopnse : (NSData *)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		[self.dict_settings writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
    }
	
}

#pragma mark -
#pragma mark LocationMannager methods

- (void) locationUpdated:(CLLocation*)newLocation {
	
	if ([[self.dict_settings objectForKey:@"currnetLocAsDefault"] intValue]) {
		
		CLLocation *oldLocation = [self getAcctualDeviceValues];
		NSDate *currentTime = [NSDate date];
		if ([currentTime timeIntervalSinceDate:self.latestLocationUpdatedBeforeTime] > 300.0) {
			self.latestLocationUpdatedBeforeTime = currentTime;
			CLLocationDistance distance = [oldLocation distanceFromLocation:newLocation];
			if (distance > 10.0) {
				NSString *latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
				NSString *longitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
				[api_tyke markUserPosition:latitude Longitude:longitude];
			}
		}
	}
}

- (void) locationUpdatedFailedWithError:(NSError*)error {
	[self showLocationError];
}


- (void) removeLocationListner : (id) viewCont {
	[loc_Manager removeListner:viewCont];
}

- (void) addLocationListner : (id) viewCont {
	[loc_Manager addListner:viewCont];
}

- (CLLocation*) getAcctualDeviceValues {
	return [loc_Manager getCurrentLocation];
}

- (void) showLocationError {
	
}

- (CLLocation*) getCurrentLocation {
	
	CLLocation *currLoc = nil;
	if ([[self.dict_settings objectForKey:@"currnetLocAsDefault"] intValue]) {
		//use zipcode value
		
		id zipData = [[self.dict_userInfo objectForKey:@"response"] objectForKey:@"zipGeoLoc"];
		if ([zipData isKindOfClass:[NSDictionary class]]) {
			CLLocationDegrees latitude = [[zipData objectForKey:@"Lat"] doubleValue];
			CLLocationDegrees longitude = [[zipData objectForKey:@"Long"] doubleValue];
			currLoc = [[[CLLocation alloc] initWithLatitude:latitude  longitude:longitude] autorelease];
			if (!isValidLocation(currLoc)) {
				currLoc = nil;
			}
		}
	}else {
		//use phone's location
		currLoc = [loc_Manager getCurrentLocation];
	}
	
	return currLoc;
}

#pragma mark -
#pragma mark Loading View

- (void) addLoadingView : (UIView*)vi_main {
	
	if (!vi_main) {
		vi_main = window;
 	}
	vxtLoadingView *vi;// = (vxtLoadingView*)[vi_main viewWithTag:7711];
	//	if (!vi) {
	vi = [[vxtLoadingView alloc] initWithFrame:CGRectMake(0, 0, vi_main.frame.size.width, vi_main.frame.size.height+2)];
	vi.tag = 7711;
	vi.backgroundColor = [UIColor blackColor];
	vi.alpha = 0.9f;
	[vi_main addSubview:vi];
	[vi release];
	//	}else {
	//		[vi_main bringSubviewToFront:vi];
	//	}
}

- (void) removeLoadingView : (UIView*)vi_main {
	if (!vi_main) {
		vi_main = window;
 	}
	UIView *vi = [vi_main viewWithTag:7711];
	if(vi){
		[vi removeFromSuperview];
	}
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (FaceBookEngine*) getFaceBookObj {
	if (!objFaceBook) {
		objFaceBook= [[FaceBookEngine alloc] init];
	}
	
	return objFaceBook;
}

- (void) cannotBeAbleToLogin {
	[self.nav_playDate.view removeFromSuperview];
	[self.nav_playDate release];
	
	[self.vi_sideView removeFromSuperview];
	
	LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
	self.nav_login = [[UINavigationController alloc] initWithRootViewController:login];
//	self.nav_login.navigationBar.tintColor = [UIColor colorWithRed:0.623 green:0.850 blue:0.996 alpha:1];
    self.nav_login.navigationBar.tintColor = [UIColor colorWithRed:0.058f green:0.219f blue:0.418f alpha:1.0];
	[login release];
	[window addSubview:self.nav_login.view];
	
	self.topNavigationController = self.nav_login;
	[self.vi_sideView setUserInteractionEnabled:YES];
	[self bringSideViewToFront];
}

#pragma mark -
#pragma mark Tyke Api Delegate

- (void) MarkUserPosResponse : (NSData*)data {
	
	[self removeLoadingView:nil];
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		[self drawTabBar];
	}
}


- (void) logInResponce : (NSData*) data {
	
	BOOL success  = NO;
	NSDictionary *response = [[data stringValue] JSONValue];
	
	if ([response objectForKey:@"responseStatus"]) {
		if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
			[self.dict_userInfo setObject:[[response objectForKey:@"response"] objectForKey:@"sessionID"] forKey:@"sessionID"];
			[self.dict_userInfo setObject:[response objectForKey:@"response"] forKey:@"response"];
			[self.dict_userInfo writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userInfo.plist"] atomically:NO];
			success = YES;
		}
	}
	
	if (!success) {
		
		[self removeLoadingView:nil];
		[self.dict_userInfo setObject:@"" forKey:@"user_name"];
		[self.dict_userInfo setObject:@"" forKey:@"password"];
		[self.dict_userInfo setObject:@"" forKey:@"sessionID"];
		[self.dict_userInfo writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userInfo.plist"] atomically:NO];
		[self cannotBeAbleToLogin];
	}else {
		
		if ([[[response objectForKey:@"response"] objectForKey:@"ProfileCompletionStatus"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
			[self homeButtonClicked:@"Settings"];
		}
		
			if ([[[response objectForKey:@"response"] objectForKey:@"AccountConfirmationFlag"] intValue]) {
				[api_tyke getUserSettings];
		} else {
			if ([[[response objectForKey:@"response"] objectForKey:@"AccountDaysEff"] intValue] > 7 ) {
				[self removeLoadingView:nil];
				userAuthentication *user = [[userAuthentication alloc] initWithNibName:@"userAuthentication" bundle:nil];
				self.nav_playDate = [[UINavigationController alloc] initWithRootViewController:user];
//				self.nav_playDate.navigationBar.tintColor = [UIColor colorWithRed:0.623 green:0.850 blue:0.996 alpha:1];
                self.nav_playDate.navigationBar.tintColor = [UIColor colorWithRed:0.058f green:0.219f blue:0.418f alpha:1.0];
				[user release];
				[self.window addSubview:self.nav_playDate.view];
			}else {
				[api_tyke getUserSettings];
			}
		}
	}
}

- (void) getUserSettingsResponse : (NSData *)data {
	
	[DELEGATE removeLoadingView:[DELEGATE window]];		
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		
//		[self.dict_settings setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"boolUserLocationCurrentLocationSetting"] intValue]] forKey:@"currnetLocAsDefault"];
		[self.dict_settings setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"boolUserNotificationGeneralMessages"] intValue]] forKey:@"generalMessages"];
		[self.dict_settings setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"boolUserNotificationMembershipRequest"] intValue]] forKey:@"membershipRequest"];
		[self.dict_settings setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"boolUserNotificationPlaydate"] intValue]] forKey:@"playdate"];
		[self.dict_settings setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"boolUserNotificationPlaydateMessageBoard"] intValue]] forKey:@"messageBoard"];
		[self.dict_settings setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"txtUserContactSetting"]intValue]] forKey:@"contactOpt"];
		[self.dict_settings setObject:[NSString stringWithFormat:@"%d", [[[response objectForKey:@"response"] objectForKey:@"txtUserProfileSetting"]intValue]] forKey:@"viewProfileOpt"];
		[self.dict_settings writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
/*
		if ([[self.dict_settings objectForKey:@"currnetLocAsDefault"] intValue]) {
			[self switchLocationManagerOn:NO];
		}else {
			[self switchLocationManagerOn:YES];
		}
*/ 
        [self switchLocationManagerOn:YES];
		[self drawTabBar];
	}
}

- (void) getKidsResponse : (NSData*) data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	self.arr_kidsList = [[NSMutableArray alloc]init];
	self.arr_kidsList = [[response objectForKey:@"response"] objectForKey:@"kids"];
	[self removeLoadingView:nil];
	//[DELEGATE setArr_kidsList:self.arr_Data];
}

- (void) noNetworkConnection {
	
	[self cannotBeAbleToLogin];
	[self removeLoadingView:nil];
}

- (void) failWithError : (NSError*) error {
	
	[self cannotBeAbleToLogin];
	[self removeLoadingView:nil];
}

- (void) requestCanceled {
	
	[self cannotBeAbleToLogin];
	[self removeLoadingView:nil];
}
#pragma mark -
#pragma mark UIAlertViewDelegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 300) {
		[self logOutCurrentUser];
	}
}

- (void)dealloc {
	[self.nav_Settings release];
	[self.nav_dashBoard release];
	[self.nav_login release];
	[self.nav_playDate release];
	[self.dict_userInfo release];
	[home_viewCont release];
    [window release];
    [super dealloc];
}

@end
