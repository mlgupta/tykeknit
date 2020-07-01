//
//  TykeKnitLoginVC.m
//  TykeKnit
//
//  Created by Abhinit Tiwari on 05/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TykeKnitLoginVC.h"
#import "UserRegStepOne.h"
#import "UserRegStepTwo.h"
#import "MenuInviteFrds.h"
#import "LoginViewController.h"

@implementation TykeKnitLoginVC

- (void) viewWillAppear:(BOOL)animated {
	
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[super viewWillAppear:animated];
}

- (void)viewDidLoad {
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleView];
	[super viewDidLoad];
}

- (void) funJoinNow : (id) sender{
	
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	
	UserRegStepOne *userRegStepOne = [[UserRegStepOne alloc] initWithNibName:@"UserRegStepOne" bundle:nil];
	userRegStepOne.prevContImage = currentImage;
	[self.navigationController pushViewController:userRegStepOne animated:NO];
	[userRegStepOne release];
}

- (void) funSignIn : (id) sender{
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	
	LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
	login.prevContImage = currentImage;
	[self.navigationController pushViewController:login animated:NO];
	[login release];
}

- (void)dealloc {

    [super dealloc];
}


@end
