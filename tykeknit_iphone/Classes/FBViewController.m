//
//  FBViewController.m
//  TykeKnit
//
//  Created by Abhinit Tiwari on 22/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FBViewController.h"
#import "TykeKnitAppDelegate.h"
#import "Global.h"


@implementation FBViewController
@synthesize dictUserInfo;


- (void)viewDidLoad {
	
	self.dictUserInfo = [[NSMutableDictionary alloc] init];
	objFaceBook = [DELEGATE getFaceBookObj];
	objFaceBook.delegate = self;

	if (![objFaceBook isLoggedIn]) {
		[objFaceBook login];
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm" message:@"You are already logged in to facebook account. You have to logout first before continue ?" delegate:self
											  cancelButtonTitle:@"Cancel" otherButtonTitles:@"Logout", nil];
		alert.tag = 77;
		[alert show];
		[alert release];
	}
	
	
    [super viewDidLoad];
}


- (void) dialogDismissed {
		[self.navigationController popViewControllerAnimated:YES];
}

- (void) loggedIn {
	
}

- (void) loggedOut {
	
	//if (!loadingRequest) {
//		[m_faceBookEngine login];
//	}
	
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) userInfoRecived:(UserInfo*)userInfo {
	
	[self.dictUserInfo setObject:[userInfo.detailedInfo objectForKey:@"email"] forKey:@"email"];

}

- (void) facebookFriendInfoDidload: (NSMutableArray*) userInfo {
	
}
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if(alertView.tag == 77){
		if(buttonIndex == 1){
			[objFaceBook logOutCurrentUser];
		}
	}
}




- (void) noNetworkConnection{
	
	//[DELEGATE removeLoadingView:self.view];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) failWithError : (NSError*) error {
	
//	[DELEGATE removeLoadingView:self.view];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void) requestCanceled {
//	[DELEGATE removeLoadingView:self.view];
	[self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
