//
//  RightSideView.m
//  TykeKnit
//
//  Created by Abhinav Singh on 11/01/11.
//  Copyright 2011 Vercingetorix Technologies. All rights reserved.
//
#import "PlayDateViewController.h"
#import "RightSideView.h"
#import "Global.h"
#import <QuartzCore/QuartzCore.h>
#import "HomeViewController.h"
#import "TykeKnitApi.h"
#import "JSON.h"
#define BORDER_WIDTH 6


@implementation RightSideView
@synthesize delegate, btn_currentSelected,img_back,btn_wannaHang,btn_home,btn_settings_wannaHang,loadedView;
@synthesize btn_playDate1,btn_playDateSearch,btn_playDate_send,btn_dashboard_wannaHang,btn_dashBoard1,btn_dashBoard2,btn_dashBoard3,btn_dashBoard4,btn_settings1,btn_settings2,btn_settings3,btn_settings4,btn_events1,btn_events2;


- (void) hideRightSideView {
	[UIView beginAnimations:@"sideview animation" context:nil];
	[UIView setAnimationDuration:Trans_Duration];
	[self setFrame:CGRectMake(320, 0, 40, 100)];
	[UIView commitAnimations];
}

- (void) showRightSideView {
	[UIView beginAnimations:@"sideview animation" context:nil];
	[UIView setAnimationDuration:Trans_Duration];
	[self setFrame:CGRectMake(280, 0, 40, 418)];
	[UIView commitAnimations];
}
- (id) initWithFrame : (CGRect)frame1 {
    
    self = [super initWithFrame:frame1];
    if (self) {
		[self setBackgroundColor:[UIColor blackColor]];
		
		self.img_back = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 418)];
		[self.img_back setBackgroundColor:[UIColor clearColor]];
		[self.img_back setImage:[[UIImage imageNamed:@"tab_grad.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:22]];
		self.img_back.contentMode = UIViewContentModeScaleToFill;
		[self.img_back setAlpha:0.75];
		[self addSubview:self.img_back];
		[self.img_back release];

		self.loadedView = @"playDate";//self.vi_playDate;

        self.btn_home = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.btn_home setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_common_home")] forState:UIControlStateNormal];
		[self.btn_home addTarget:self action:@selector(homebtnClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.btn_home.frame = CGRectMake(0, 40, 38, 47);
		[self addSubview:self.btn_home];
		
		self.btn_wannaHang = [UIButton buttonWithType:UIButtonTypeCustom];
        //		[self.btn_wannaHang setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_playdate_wannaHang")] forState:UIControlStateNormal];
		[self.btn_wannaHang setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_playdate_wannaHang")] forState:UIControlStateNormal];
//		[self.btn_wannaHang addTarget:self action:@selector(wannaHangClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.btn_wannaHang addTarget:self action:@selector(playdateClicked:) forControlEvents:UIControlEventTouchUpInside];
        self.btn_wannaHang.tag = 1;
		self.btn_wannaHang.frame =  CGRectMake(0, 101, 39, 49);
		[self.btn_wannaHang setBackgroundColor:[UIColor clearColor]];
		[self insertSubview:self.btn_wannaHang belowSubview:self.img_back];
		
		self.btn_playDateSearch = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.btn_playDateSearch addTarget:self action:@selector(playdateClicked:) forControlEvents:UIControlEventTouchUpInside];
        //		[self.btn_playDateSearch setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_playdate_search")] forState:UIControlStateNormal];
		[self.btn_playDateSearch setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName (@"btn_playdate_search")] forState:UIControlStateNormal];
		self.btn_playDateSearch.tag = 2;
		self.btn_playDateSearch.frame = CGRectMake(0, 166, 39, 49);
		[self addSubview:self.btn_playDateSearch];
		
		self.btn_playDate_send = [UIButton buttonWithType:UIButtonTypeCustom];
		[self.btn_playDate_send addTarget:self action:@selector(playdateClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.btn_playDate_send.tag = 3;
		[self.btn_playDate_send setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_playdate_plan")] forState:UIControlStateNormal];
		[self.btn_playDate_send setContentMode:UIViewContentModeScaleToFill];
		btn_playDate_send.frame = CGRectMake(0, 231, 39, 49);
        //		btn_playDate_send.frame = CGRectMake(0, 200, 41, 50);
		[self insertSubview:self.btn_playDate_send belowSubview:self.img_back];
		
		self.btn_dashBoard1 = [UIButton buttonWithType:UIButtonTypeCustom];
		self.btn_dashBoard1.tag = 1;
		[self.btn_dashBoard1 setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_dashboard_playdates")] forState:UIControlStateNormal];
		[self.btn_dashBoard1 addTarget:self action:@selector(dashBoardClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.btn_dashBoard1.frame = CGRectMake(40, 101, 39, 49);
		[self insertSubview:self.btn_dashBoard1 belowSubview:self.img_back];
		
		self.btn_dashBoard2 = [UIButton buttonWithType:UIButtonTypeCustom];
		self.btn_dashBoard2.tag = 2;
		[self.btn_dashBoard2 setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_dashboard_messages")] forState:UIControlStateNormal];
		[self.btn_dashBoard2 addTarget:self action:@selector(dashBoardClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.btn_dashBoard2.frame = CGRectMake(40, 166, 39, 49);
		[self insertSubview:self.btn_dashBoard2 belowSubview:self.img_back];
		
		self.btn_dashBoard3= [UIButton buttonWithType:UIButtonTypeCustom];
		self.btn_dashBoard3.tag = 3;
		[self.btn_dashBoard3 addTarget:self action:@selector(dashBoardClicked:) forControlEvents:UIControlEventTouchUpInside];
		[self.btn_dashBoard3 setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_dashboard_friends")] forState:UIControlStateNormal];
		self.btn_dashBoard3.frame = CGRectMake(40, 231, 39, 49);
		[self insertSubview:self.btn_dashBoard3 belowSubview:self.img_back];
        
		self.btn_settings1 = [UIButton buttonWithType:UIButtonTypeCustom];
		self.btn_settings1.tag = 1;
		[self.btn_settings1 setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_settings_accounts")] forState:UIControlStateNormal];
		[self.btn_settings1 addTarget:self action:@selector(settingsClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.btn_settings1.frame = CGRectMake(40, 101, 39, 49);
		[self addSubview:btn_settings1];
		
		self.btn_settings3 = [UIButton buttonWithType:UIButtonTypeCustom];
		self.btn_settings3.tag = 3;
		[self.btn_settings3 addTarget:self action:@selector(settingsClicked:) forControlEvents:UIControlEventTouchUpInside];
		[self.btn_settings3 setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_settings_personal")] forState:UIControlStateNormal];
        //		self.btn_settings3.frame = CGRectMake(40, 297, 39, 49);
		self.btn_settings3.frame = 	CGRectMake(40, 166, 39, 49);
		[self insertSubview:self.btn_settings3 belowSubview:self.img_back];
        
		self.btn_events1 = [UIButton buttonWithType:UIButtonTypeCustom];
		self.btn_events1.tag = 1;
		[self.btn_events1 setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_events_view")] forState:UIControlStateNormal];
		[self.btn_events1 addTarget:self action:@selector(eventsClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.btn_events1.frame = CGRectMake(40, 101, 39, 49);
		[self addSubview:btn_events1];
		
		self.btn_events2 = [UIButton buttonWithType:UIButtonTypeCustom];
		self.btn_events2.tag = 2;
		[self.btn_events2 setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_events_post")] forState:UIControlStateNormal];
		[self.btn_events2 addTarget:self action:@selector(eventsClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.btn_events2.frame = 	CGRectMake(40, 166, 39, 49);
		[self insertSubview:self.btn_events2 belowSubview:self.img_back];
    }
    return self;
}

- (void) getUserProfileResponse : (NSData *)data {
	[DELEGATE removeLoadingView:self];
	NSDictionary *response = [[data stringValue] JSONValue];
		if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
	}
}

- (void) hideWannaHangButton {
	
	[UIView beginAnimations:@"" context:@""];
	[UIView setAnimationDuration:0.3];
	[btn_wannaHang setFrame:CGRectMake(45, 30, 35, 35)];
	[UIView commitAnimations];
}

- (void) showWannaHangButton {
	
	[UIView beginAnimations:@"" context:@""];
	[UIView setAnimationDuration:0.3];
	[btn_wannaHang setFrame:CGRectMake(0, 30, 35, 45)];
	[UIView commitAnimations];
}

- (void) homebtnClicked : (id) sender {
	/*
//	[[DELEGATE window] exchangeSubviewAtIndex:[[[DELEGATE window] subviews] indexOfObject:[DELEGATE vi_sideView]] 
//						   withSubviewAtIndex:[[[DELEGATE window] subviews] indexOfObject:[DELEGATE vi_sideView]]-1];
	[DELEGATE.window endEditing:YES];
	//HomeViewController *homeview = [DELEGATE home_viewCont];
	HomeViewController *homeView = (HomeViewController *)[[DELEGATE topNavigationController].topViewController modalViewController];
	if (!homeView) {
			homeView = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
	}
	[[DELEGATE topNavigationController].topViewController presentModalViewController:homeView animated:YES];
	[DELEGATE putSideViewToBack];	
	*/
	
	[DELEGATE.window endEditing:YES];
	HomeViewController *homeview = [DELEGATE home_viewCont];
	if (!homeview) {
		
		homeview = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
		[[DELEGATE nav_playDate] pushViewController:homeview animated:NO];
		
		//		homeview = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
		//		UINavigationController *nav_home = [[UINavigationController alloc]initWithRootViewController:homeview];
		//		[self.window addSubview:nav_home.view];
		//		homeview = [[[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil] autorelease];
		//		homeview.view.frame = CGRectMake(0, 20, 320, 460);
	}
	
	[homeview.view setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.001f, 0.001f)];
	[UIView beginAnimations:@"addhomeview" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[homeview.view setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f)];
	[UIView commitAnimations];
	//	[[DELEGATE window] addSubview:homeview.view];
	[[DELEGATE window] addSubview:homeview.navigationController.view];
	
}

- (void) setBtn_currentSelected : (UIButton*) newSelected {
	
	if ([newSelected isEqual:self.btn_currentSelected]) {
		return;
	}
	
	if (self.btn_currentSelected) {
		
		if ([self.btn_currentSelected isEqual:self.btn_playDate1]) {
			[self hideWannaHangButton];
		}
	}
	
	if ([newSelected isEqual:self.btn_playDate1]) {
		[self showWannaHangButton];
	}
	
	btn_currentSelected = newSelected;
}

-(void) moveAnimation : (NSString *) vi_name {
	
	[UIView beginAnimations:@"sideview animation" context:nil];
	[UIView setAnimationDuration:Trans_Duration];

    if ([vi_name isEqualToString:@"DashBoard"]) {
		[self.btn_wannaHang setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_playDateSearch setFrame:CGRectMake(40,166, 39, 49)];
		[self.btn_playDate_send setFrame:CGRectMake(40, 231, 39, 49)];
		
		[self.btn_settings1 setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_settings3 setFrame:CGRectMake(40, 166, 39, 49)];
        
		[self.btn_dashBoard1 setFrame:CGRectMake(0, 101, 39, 49)];
		[self.btn_dashBoard2 setFrame:CGRectMake(0, 166, 39, 49)];
		[self.btn_dashBoard3 setFrame:CGRectMake(0, 231, 39, 49)];
        
        [self.btn_events1 setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_events2 setFrame:CGRectMake(40, 166, 39, 49)];
        
	}else if ([vi_name isEqualToString:@"playDate"]) {
		[self.btn_wannaHang setFrame:CGRectMake(0, 101, 39, 49)];
		[self.btn_playDateSearch setFrame:CGRectMake(0,166, 39, 49)];
		[self.btn_playDate_send setFrame:CGRectMake(0, 231, 39, 49)];
		
		[self.btn_settings1 setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_settings3 setFrame:CGRectMake(40, 166, 39, 49)];
		
		[self.btn_dashBoard1 setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_dashBoard2 setFrame:CGRectMake(40, 166, 39, 49)];
		[self.btn_dashBoard3 setFrame:CGRectMake(40, 231, 39, 49)];

        [self.btn_events1 setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_events2 setFrame:CGRectMake(40, 166, 39, 49)];
	}else if ([vi_name isEqualToString:@"Settings"]) {
        
		[self.btn_wannaHang setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_playDateSearch setFrame:CGRectMake(40,166, 39, 49)];
		[self.btn_playDate_send setFrame:CGRectMake(40, 231, 39, 49)];
        
		
		[self.btn_settings1 setFrame:CGRectMake(0, 101, 39, 49)];
		[self.btn_settings3 setFrame:CGRectMake(0, 166, 39, 49)];
        
		[self.btn_dashBoard1 setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_dashBoard2 setFrame:CGRectMake(40, 166, 39, 49)];
		[self.btn_dashBoard3 setFrame:CGRectMake(40, 231, 39, 49)];
        
        [self.btn_events1 setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_events2 setFrame:CGRectMake(40, 166, 39, 49)];
	}else if ([vi_name isEqualToString:@"Events"]) {
		[self.btn_wannaHang setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_playDateSearch setFrame:CGRectMake(40,166, 39, 49)];
		[self.btn_playDate_send setFrame:CGRectMake(40, 231, 39, 49)];
		
		[self.btn_settings1 setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_settings3 setFrame:CGRectMake(40, 166, 39, 49)];
        
		[self.btn_dashBoard1 setFrame:CGRectMake(40, 101, 39, 49)];
		[self.btn_dashBoard2 setFrame:CGRectMake(40, 166, 39, 49)];
		[self.btn_dashBoard3 setFrame:CGRectMake(40, 231, 39, 49)];
        
        [self.btn_events1 setFrame:CGRectMake(0, 101, 39, 49)];
		[self.btn_events2 setFrame:CGRectMake(0, 166, 39, 49)];
	}


	[UIView commitAnimations];
}

- (void) loadView :(NSString *) vi_name {
	
	if (![vi_name isEqualToString:self.loadedView]) {
		[self moveAnimation:vi_name];
		self.loadedView = vi_name;
	}
}

/*
- (void) wannaHangClicked : (id) sender {
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"WannaHang" object:self];
	if ([self.loadedView isEqualToString:@"playDate"]) {
		[self insertSubview:self.btn_wannaHang aboveSubview:self.img_back];
		[self insertSubview:self.btn_playDate_send belowSubview:self.img_back];
		[self insertSubview:self.btn_playDateSearch belowSubview:self.img_back];
	} else if ([self.loadedView isEqualToString:@"DashBoard"]) {
		[self insertSubview:self.btn_dashboard_wannaHang aboveSubview:self.img_back];
		[self insertSubview:self.btn_dashBoard1 belowSubview:self.img_back];
		[self insertSubview:self.btn_dashBoard2 belowSubview:self.img_back];
		[self insertSubview:self.btn_dashBoard3 belowSubview:self.img_back];
	} else if ([self.loadedView isEqualToString:@"Settings"]) {
		[self insertSubview:self.btn_settings_wannaHang aboveSubview:self.img_back];
		[self insertSubview:self.btn_settings1 belowSubview:self.img_back];
		[self insertSubview:self.btn_settings2 belowSubview:self.img_back];
		[self insertSubview:self.btn_settings3 belowSubview:self.img_back];
	} else if ([self.loadedView isEqualToString:@"Events"]) {
		[self insertSubview:self.btn_events1 belowSubview:self.img_back];
		[self insertSubview:self.btn_events2 belowSubview:self.img_back];
	}
	
	[DELEGATE buttonClickedNamed:@"WannaHang"];
}
*/
 
- (void) dashBoardClicked : (id) sender {
	
	self.btn_currentSelected = (UIButton*)sender;
	if (self.btn_currentSelected.tag == 1) {
		[self.delegate buttonClickedNamed:@"Playdates"];
	} else if (self.btn_currentSelected.tag == 2) {
		[self.delegate buttonClickedNamed:@"Messages"];
	} else if (self.btn_currentSelected.tag == 3) {
		[self.delegate buttonClickedNamed:@"Friends"];
	}
}

- (void) showFramesOfAllButtons {
	
	for (UIButton *btn in [self subviews]) {
	}
}

- (void) settingsClicked : (id) sender {
	
	self.btn_currentSelected = (UIButton*)sender;
	if (self.btn_currentSelected.tag == 1) {
		[self.delegate buttonClickedNamed:@"Account"];
	} else if (self.btn_currentSelected.tag == 2) {
		[self.delegate buttonClickedNamed:@"Notifications"];
	} else if (self.btn_currentSelected.tag == 3) {
		[self.delegate buttonClickedNamed:@"General"];
	}
}

- (void) eventsClicked : (id) sender {
	
	self.btn_currentSelected = (UIButton*)sender;
	if (self.btn_currentSelected.tag == 1) {
		[self.delegate buttonClickedNamed:@"AllEvents"];
	} else if (self.btn_currentSelected.tag == 2) {
		[self.delegate buttonClickedNamed:@"AddEvent"];
	}
}

- (void) playdateClicked : (id) sender {
	
	self.btn_currentSelected = (UIButton*)sender;
	
	if (self.btn_currentSelected.tag == 2) {
		[self.delegate buttonClickedNamed:@"Search"];
	} else if (self.btn_currentSelected.tag == 3) {
		[self.delegate buttonClickedNamed:@"Send"];
	} else if (self.btn_currentSelected.tag == 1) {
		[self.delegate buttonClickedNamed:@"WannaHang"];
	}
}

- (void)dealloc {

    [super dealloc];
}

@end




