//
//  FriendsMainViewController.m
//  SpotWorld
//
//  Created by Abhinit Tiwari on 14/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FriendsMainViewController.h"
#import "Global.h"
#import "JSON.h"
#import "VXTImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "InviteFriendsEmailViewController.h"
#import "AddFacebookFriendsViewController.h"
#import "AddAddressbookFriendsViewController.h"
#import "FaceBookEngine.h"
#import "Messages.h"

@implementation FriendsMainViewController
@synthesize theTableView,rightSideView,api;
//Synthesize Views
@synthesize topView, middleView;

//Synthesize Other Vars
@synthesize friendsCount, friendsArray,arr_fbFriendsInfo, dictUserInfo;

- (void)viewDidLoad {
	
	self.navigationItem.titleView  = [DELEGATE getTykeTitleViewWithTitle:@"Add"];

    api = [[TykeKnitApi alloc]init];
	api.delegate = self;

	[self.navigationItem setHidesBackButton:YES];
	
	UIButton *btn_skip = [DELEGATE getDefaultBarButtonWithTitle:@"Skip"];
	[btn_skip addTarget:self action:@selector(btn_skipPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn_skip] autorelease];
	
//	self.rightSideView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 0, 45, 418)];
//	[self.rightSideView setBackgroundColor:[UIColor clearColor]];
//	[self.rightSideView setImage:[[UIImage imageNamed:@"tab_grad.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:22]];
//	[self.rightSideView setAlpha:1.0];
//	[self.view addSubview:self.rightSideView];
//	[self.rightSideView release];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	[self.theTableView setBackgroundColor:[UIColor clearColor]];
	
	[super viewDidLoad];
}
- (void) btn_skipPressed : (id) sender {
	if (![[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"AccountConfirmationFlag"] intValue]) {
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		[DELEGATE userLoggedInWithDict:[DELEGATE dict_userInfo]];

		//				[api_tyke resendConfirmationURL];
		//UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
		//												   message:@"Please confirm your account by clicking on confirmation link sent to your EmailId."// MSG_ERROR_VALID_REGISTER4
		//												  delegate:self 
		//										 cancelButtonTitle:@"Ok" 
		//										 otherButtonTitles:nil];
		//[objAlert show];
		//[objAlert setTag:301];
		//[objAlert release];
	}else { //should not come here !
	}

}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 301) {
		[DELEGATE cannotBeAbleToLogin];
	}
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
	[self.friendsArray release];
	[self.topView release];
	[self.middleView release];
    [super dealloc];
}

#pragma mark -
#pragma mark API CALLBACK
- (void) noNetworkConnection {
//	[DELEGATE removeLoadingView:self.view];
}

- (void) failWithError : (NSError*) error {
//	[DELEGATE removeLoadingView:self.view];
}

- (void) requestCanceled {
//	[DELEGATE removeLoadingView:self.view];
}

- (void) authenticationCancled {
//	[DELEGATE removeLoadingView:self.view];
}

#pragma mark -
#pragma mark UITableViewDelegate & dataSource methods.

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *view_ForHeader = [[[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)] autorelease];
	
	UILabel *headerForSection = [[UILabel alloc]initWithFrame:CGRectMake(20, -5, 150, 23)];
	[headerForSection setBackgroundColor:[UIColor clearColor]];
	headerForSection.font = [UIFont boldSystemFontOfSize:16];
	headerForSection.text = @"Build Your Knit";
	headerForSection.textColor = [UIColor darkGrayColor];
	[view_ForHeader addSubview:headerForSection];
	[headerForSection release];
	
	return view_ForHeader;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 25.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 90)] autorelease];
	
	UILabel *headerName = [[UILabel alloc] initWithFrame:CGRectMake(14, -20, 265, 110)];
	headerName.textAlignment = UITextAlignmentLeft;
	headerName.numberOfLines = 3;
	headerName.textColor =  [UIColor darkGrayColor];
	headerName.text = @"We do not store information about your contacts. Information you provide to	add friends is only used to send invitations on your behalf.";
	[headerName setFont:[UIFont fontWithName:@"helvetica Neue Thin" size:10]];
	[headerName setFont:[UIFont boldSystemFontOfSize:11]];
	headerName.backgroundColor = [UIColor clearColor];
	[vi addSubview:headerName];
	[headerName release];
	return vi;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
//	int rowIndex = [indexPath row];
	NSString *friendCell = @"friendCell";
	UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:friendCell];
	if(cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendCell] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];

//		UIView *viBack = [[UIView alloc] initWithFrame:CGRectZero];
//		viBack.backgroundColor = [UIColor whiteColor];
//		cell.backgroundView = viBack;
//		[viBack release];

		UITextField *txt_Cell = [[UITextField alloc] initWithFrame:CGRectMake(10, 3, 200, 30)];
		txt_Cell.tag = 1;
		[txt_Cell setUserInteractionEnabled:NO];
		txt_Cell.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[txt_Cell setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		txt_Cell.font = [UIFont systemFontOfSize:15];
		txt_Cell.autocorrectionType = UITextAutocorrectionTypeNo;
		txt_Cell.backgroundColor = [UIColor clearColor];
		[txt_Cell setKeyboardType:UIKeyboardTypeAlphabet];
		[cell.contentView addSubview:txt_Cell];               
		[txt_Cell release];
		
		UIImageView *img_Cell = [[UIImageView alloc]initWithFrame:CGRectMake(255, 2, 34, 34)];
		[img_Cell setTag:2];
		[cell.contentView addSubview:img_Cell];
		[img_Cell release];
		
	}

	UITextField *txt_Cell = (UITextField *)[cell viewWithTag:1];
	UIImageView *img_Cell = (UIImageView *)[cell viewWithTag:2];

	switch (indexPath.row) {
		case 0:
			txt_Cell.placeholder = @"Address Book";
			img_Cell.image = [UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"img_addressBook.png")];
			break;
		case 1:
//			txt_Cell.placeholder = @"Email";
//			[img_Cell setFrame:CGRectMake(254, 2, 35, 34)];
//			img_Cell.image = [UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"img_email.png")];
//			break;
			txt_Cell.placeholder = @"Facebook";
			img_Cell.image = [UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"img_inviteFriendsFacebook.png")];
			break;
		case 2:
			txt_Cell.placeholder = @"Email";
				[img_Cell setFrame:CGRectMake(254, 2, 35, 34)];
			img_Cell.image = [UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"img_email.png")];
			break;
		default:
			break;
	}
	return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;//[self.dictTykeData count]*3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Load the friend profile here.
	if (indexPath.row == 0) {
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		AddAddressbookFriendsViewController *invite = [[AddAddressbookFriendsViewController alloc]initWithNibName:@"AddAddressbookFriendsViewController" bundle:nil];
		invite.prevContImage = currentImage;
		[self.navigationController pushViewController:invite animated:NO];
		[invite release];
	}
	if (indexPath.row == 1) {
/*
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		InviteFriendsEmailViewController *invite = [[InviteFriendsEmailViewController alloc]initWithNibName:@"InviteFriendsEmailViewController" bundle:nil];
		invite.prevContImage = currentImage;
		[self.navigationController pushViewController:invite animated:NO];
		[invite release];
*/		
        if (!self.arr_fbFriendsInfo) {
			FaceBookEngine *eng = [DELEGATE getFaceBookObj];
			eng.delegate = self;
			[DELEGATE addLoadingView:self.view];
			if (![eng isLoggedIn]) {
				[eng login];	
                
                [api setFBIdToken:[self.dictUserInfo objectForKey:@"uid"] txtFBAuthToken:@""] ;
			}
		}else {
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			AddFacebookFriendsViewController *invite = [[AddFacebookFriendsViewController alloc]initWithNibName:@"AddFacebookFriendsViewController" bundle:nil];
			invite.friendsArray = self.arr_fbFriendsInfo;
			invite.prevContImage = currentImage;
			[self.navigationController pushViewController:invite animated:NO];
			[invite release];
		}
		 
	}
	if (indexPath.row == 2) {
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		InviteFriendsEmailViewController *invite = [[InviteFriendsEmailViewController alloc]initWithNibName:@"InviteFriendsEmailViewController" bundle:nil];
		invite.prevContImage = currentImage;
		[self.navigationController pushViewController:invite animated:NO];
		[invite release];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
- (void) dialogDismissed {
	[DELEGATE removeLoadingView:self.view];
}

- (void) friendsInfoReceived:(NSMutableArray*) friendsInfo {
	self.arr_fbFriendsInfo = [[NSMutableArray alloc]initWithArray:friendsInfo];
	[DELEGATE removeLoadingView:self.view];
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	AddFacebookFriendsViewController *invite = [[AddFacebookFriendsViewController alloc]initWithNibName:@"AddFacebookFriendsViewController" bundle:nil];
	invite.friendsArray = self.arr_fbFriendsInfo;
	invite.prevContImage = currentImage;
	[self.navigationController pushViewController:invite animated:NO];
	[invite release];
	
}

- (void) userInfoRecived:(UserInfo*)userInfo {
	
	[self.dictUserInfo setObject:[userInfo.detailedInfo objectForKey:@"email"] forKey:@"email"];
	[self.dictUserInfo setObject:userInfo.uid forKey:@"uid"];
    
}

@end
