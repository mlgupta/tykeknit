//
//  HomeViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 07/02/11.
//  Copyright 2011 Vercingetorix Technologies. All rights reserved.
//

#import "HomeViewController.h"
#import "Global.h"

@implementation HomeViewController
@synthesize titleHome,back;

- (void) statusBarFrameChanged:(NSNotification*)notification {
    NSValue* rectValue = [[notification userInfo] valueForKey:UIApplicationStatusBarFrameUserInfoKey];
    CGRect newFrame;
    [rectValue getValue:&newFrame];
    
    if (newFrame.size.height == 40) {
        //self.view.frame = CGRectMake(0, 40.0, 320.0, 440.0);
    } else {
        //self.view.frame = CGRectMake(0, 20, 320.0, 460.0);        
    }

}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"    Menu"];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarFrameChanged:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
//	UIButton *btn_List = [DELEGATE getBackBarButtonWithTitle:@"List"];
//	[btn_List addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
//	self.titleHome.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_List] autorelease];
	
	UIButton *btn_Cancel = [DELEGATE getDefaultBarButtonWithTitle:@"Cancel"];
	[btn_Cancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.back =[[[UIBarButtonItem alloc] initWithCustomView:btn_Cancel] autorelease];
	self.navigationItem.rightBarButtonItem = self.back;
	
}

- (void) cancelClicked: (id) sender {
//	[DELEGATE bringSideViewToFront];
//	[self dismissModalViewControllerAnimated:YES];
	[self removeView:self.view];
}

-(void) removeView : (UIView *) vi {
 
	[UIView beginAnimations:@"addhomeview" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5];
	[vi setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.001f, 0.001f)];
	[UIView commitAnimations];
	[self.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
	[self.navigationController.view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
}

- (void) playDateClicked : (id) sender {
//	[DELEGATE bringSideViewToFront];
	[DELEGATE homeButtonClicked:@"PlayDate"];
//	[self dismissModalViewControllerAnimated:YES];
	[self removeView:self.view];
}

- (void) settingsClicked : (id) sender {
//	[DELEGATE bringSideViewToFront];
	[DELEGATE homeButtonClicked:@"Settings"];
//	[self dismissModalViewControllerAnimated:YES];
	[self removeView:self.view];
}

- (void) dashBoardClicked : (id) sender {
//	[DELEGATE bringSideViewToFront];
	[DELEGATE homeButtonClicked:@"DashBoard"];
//	[self dismissModalViewControllerAnimated:YES];
	[self removeView:self.view];

}

- (void) eventsClicked : (id) sender {
    //	[DELEGATE bringSideViewToFront];
	[DELEGATE homeButtonClicked:@"Events"];
    //	[self dismissModalViewControllerAnimated:YES];
	[self removeView:self.view];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}


@end
