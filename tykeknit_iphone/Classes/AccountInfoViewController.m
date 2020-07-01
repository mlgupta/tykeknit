//
//  AccountInfoViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 07/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "AccountInfoViewController.h"
#import "Global.h"
#import "KidsListDetailViewController.h"
#import "EditKidsDetailsViewController.h"
#import "TableCellImageView.h"
#import "PrivacyViewController.h"
#import "SpouseInvitationViewController.h"
#import "GeneralTabViewController.h"
#import "NotificationsViewController.h"
#import "Global.h"
#import "UserRegStepTwo.h"
#import "JSON.h"
#import "ParentsDetailViewController.h"
#import "Messages.h"

@implementation AccountInfoViewController
@synthesize theTableView, dict_settings,rightSideView,dict_userData,api_tyke;


- (void) backPressed : (id) sender {
	
	[self popViewController];
}
- (void) viewWillAppear:(BOOL)animated {

	
	if ([[[DELEGATE window] subviews] containsObject:[DELEGATE nav_wannaHangBar].view]) {
		[[DELEGATE nav_wannaHangBar].view removeFromSuperview];
	}
	[self.rightSideView insertSubview:self.rightSideView.btn_settings1 aboveSubview:self.rightSideView.img_back];
//	[self.rightSideView insertSubview:self.rightSideView.btn_settings_wannaHang belowSubview:self.rightSideView.img_back];
	[self.rightSideView insertSubview:self.rightSideView.btn_settings2 belowSubview:self.rightSideView.img_back];
	[self.rightSideView insertSubview:self.rightSideView.btn_settings3 belowSubview:self.rightSideView.img_back];
    [[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_home belowSubview:[DELEGATE vi_sideView].img_back];

	
//	[DELEGATE addLoadingView:[DELEGATE window]];
//	[api_tyke getUserProfile:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"txtUserTblPk"]];

	self.dict_userData = [NSMutableDictionary dictionaryWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"]];
	[self.theTableView reloadData];
	[super viewWillAppear:animated];

}
- (void) viewDidLoad {

	
	//shadow for Navigationbar
	CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.5f].CGColor;
	CGColorRef lightColor = [UIColor clearColor].CGColor;
	
	CAGradientLayer *newShadow = [[[CAGradientLayer alloc] init] autorelease];
	newShadow.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.width, 7);
	newShadow.colors = [NSArray arrayWithObjects:(id)darkColor, (id)lightColor, nil];
	[self.navigationController.navigationBar.layer addSublayer:newShadow];	
	//
	
	UIButton *btn_back = [DELEGATE getDefaultBarButtonWithTitle:@"Logout"];
	[btn_back addTarget:self action:@selector(logout:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];

    UIButton *btn_delete = [DELEGATE getDefaultBarButtonWithTitle:@"Delete"];
	[btn_delete addTarget:self action:@selector(deleteAccount:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_delete] autorelease];

	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Profile"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];
	
	self.rightSideView = [DELEGATE vi_sideView];
//	self.rightSideView.delegate = self;
	if (!api_tyke) {
		api_tyke = [[TykeKnitApi alloc]init];
		api_tyke.delegate = self;
	}
	if (!dict_userData) {
		dict_userData = [[NSMutableDictionary alloc]init];
	}
	
	[DELEGATE addLoadingView:[DELEGATE window]];
	if ([[self.dict_userData objectForKey:@"userDetails"] objectForKey:@"picURL"]) {
		[DELEGATE removeFromDocDirFileName:md5([[self.dict_userData objectForKey:@"userDetails"] objectForKey:@"picURL"])];
	}
	[self.dict_userData removeAllObjects];
	[self.dict_userData writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"] atomically:NO];
	[api_tyke getUserProfile:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"txtUserTblPk"]];

	[super viewDidLoad];
}
- (void) logout:(id)sender {

	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Logout" 
												   message:TITLE_ERROR_2 
												  delegate:self 
										 cancelButtonTitle:@"Yes" 
										 otherButtonTitles:@"No",
						  nil];
	[alert setTag:302];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (alertView.tag == 300) {
		if (buttonIndex == 1) {
			if ([[self.dict_userData objectForKey:@"spouseDetails"]objectForKey:@"emailAddress"]) {
			[DELEGATE addLoadingView:self.vi_main];
			[api_tyke removeSecondaryPR:[[self.dict_userData objectForKey:@"spouseDetails"]objectForKey:@"emailAddress"]];
			}
		}
	}else if (alertView.tag == 301) {
		if (buttonIndex == 0) {
			[DELEGATE addLoadingView:self.vi_main];
			[api_tyke deleteAccount];
		}
	}else if (alertView.tag == 302) {
		if (buttonIndex==0) 
			[DELEGATE logOutCurrentUser];
		[api_facebook logout];
	}
}



- (void) deleteAccount:(id) sender {
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Delete"
												   message:@"Do you really want to delete your account?" 
												  delegate:self 
										 cancelButtonTitle:@"Yes" 
										 otherButtonTitles:@"No",nil];
	[alert show];
	[alert setTag:301];
	[alert release];
	
	
}
#pragma mark -
#pragma mark RightSideViewDelegate

- (void) buttonClickedNamed : (NSString*) name {
	
	self.dict_settings = [DELEGATE dict_settings];
	if ([name isEqualToString:@"Account"]) {
		for (UIViewController *viewCont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}

		[self.navigationController popToRootViewControllerAnimated:NO];
		[[[self.navigationController viewControllers] objectAtIndex:0] viewWillAppear:NO];
	}else if([name isEqualToString:@"Notifications"]) {
		for (UIViewController *viewCont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
		NotificationsViewController *notify = [[NotificationsViewController alloc] initWithNibName:@"NotificationsView" bundle:nil];
		notify.dict_settings = self.dict_settings;
		[self.navigationController pushViewController:notify animated:NO];
		[notify release];
	}else if([name isEqualToString:@"General"]) {

		for (UIViewController *viewCont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
		GeneralTabViewController *general = [[GeneralTabViewController alloc] initWithNibName:@"GeneralTabViewController" bundle:nil];
		general.dict_settings = self.dict_settings;
		[self.navigationController pushViewController:general animated:NO];
		[general release];
	}
}	

/*
- (BOOL) isWannaHangHighlighted {
	
	BOOL RET = NO;
	if([[DELEGATE vi_wannaHang] superview]) {
		RET = YES;
	}
	return RET;
}
*/
#pragma mark -
#pragma mark UITableViewDelagate Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
//	return 4;
	return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	int RET = 0;
	if (section == 0) {
		RET = 1;
	}else if (section == 1) {
			RET = [[self.dict_userData objectForKey:@"Kids"] count]+1;
	}else if (section == 2 || section == 3) {
		RET = 1;
	}
	return RET;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 53;
	}else if (indexPath.section == 3) {
		return 40;
	}
	return 44;
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 1) {
		return 30;
	}
	
	return 0;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (section==1){
		UIView *view_ForHeader = [[UIView alloc]initWithFrame:CGRectMake(0,0,0,20)];
		
		UILabel *headerForSection = [[[UILabel alloc]initWithFrame:CGRectMake(22, 10, 100, 17)] autorelease];
		[headerForSection setBackgroundColor:[UIColor clearColor]];
		headerForSection.font = [UIFont boldSystemFontOfSize:16];
		headerForSection.layer.shadowOffset = CGSizeMake(0, 5.0);
		headerForSection.layer.shadowColor = [UIColor whiteColor].CGColor;
		headerForSection.text = @"Tykes";
		headerForSection.textColor = [UIColor darkGrayColor];
		headerForSection.textColor = SectionHeaderColor;
		[view_ForHeader addSubview:headerForSection];
		return [view_ForHeader autorelease];
	}
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
//	int rowInd = [indexPath row];
	int section = [indexPath section];
	
	if (section == 0) {
		NSString *parentInfo = @"parentInfo";
		cell = [tableView dequeueReusableCellWithIdentifier:parentInfo];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:parentInfo] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			TableCellImageView *img_view = [[TableCellImageView alloc] initWithFrame:CGRectMake(13, 7, 40, 40)];
			img_view.defaultImage = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
			img_view.tag = 1;
			[cell.contentView addSubview:img_view];
			[img_view release];
			
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, 180, 24)];
			lblFirstName.tag = 2;
			lblFirstName.textColor = [UIColor colorWithRed:0.298 green:0.341 blue:0.420 alpha:1.0];
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font = [UIFont boldSystemFontOfSize:15];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
			
			UILabel *lbl_profile = [[UILabel alloc] initWithFrame:CGRectMake(60, 25, 280, 24)];
			lbl_profile.tag = 3;
			lbl_profile.text = @"Profile";
			lbl_profile.textColor = [UIColor lightGrayColor];
			lbl_profile.backgroundColor = [UIColor clearColor];
			lbl_profile.font = [UIFont systemFontOfSize:13];
			[cell.contentView addSubview:lbl_profile];
			[lbl_profile release];
		}
		
		TableCellImageView *img_view = (TableCellImageView *)[cell.contentView viewWithTag:1];
		UILabel *lbl_Name = (UILabel*)[cell viewWithTag:2];
		
		if ([[self.dict_userData objectForKey:@"userDetails"] objectForKey:@"firstName"] &&[[self.dict_userData objectForKey:@"userDetails"] objectForKey:@"lastName"]) {
			lbl_Name.text = [NSString stringWithFormat:@"%@ %@",[[self.dict_userData objectForKey:@"userDetails"] objectForKey:@"firstName"],[[self.dict_userData objectForKey:@"userDetails"] objectForKey:@"lastName"]];
		}

		if ([[self.dict_userData objectForKey:@"userDetails"] objectForKey:@"imgFile"]) {
			[img_view setImage:[UIImage imageWithContentsOfFile:[[self.dict_userData objectForKey:@"userDetails"] objectForKey:@"imgFile"]]];
		}else {
		[img_view setImageUrl:[[self.dict_userData objectForKey:@"userDetails"] objectForKey:@"picURL"]];
		}
		return cell;
	}else if (section == 1) {
		NSString *addMoreTyke = @"addMoreTyke";
		cell = [tableView dequeueReusableCellWithIdentifier:addMoreTyke];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:addMoreTyke] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, 100, 20)];
			lblFirstName.tag = 11; 
			[lblFirstName setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font = [UIFont fontWithName:@"helvetica Neue" size:16];
			lblFirstName.font = [UIFont systemFontOfSize:16];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
			
			UILabel *lbl_childAge = [[UILabel alloc]initWithFrame:CGRectMake(15, 15, 100, 20)];
			[lbl_childAge setTag:12];
			[lbl_childAge setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			[lbl_childAge setBackgroundColor:[UIColor clearColor]];
			lbl_childAge.font = [UIFont fontWithName:@"helvetica Neue" size:15];
			[lbl_childAge setFont:[UIFont systemFontOfSize:15]];
			[cell.contentView addSubview:lbl_childAge];
			[lbl_childAge release];
			
			UIButton *btn_addTyke = [UIButton buttonWithType:UIButtonTypeContactAdd];
			[btn_addTyke setFrame:CGRectMake(225, 7, 30, 30)];
			[btn_addTyke addTarget:self action:@selector(addTykes:) forControlEvents:UIControlEventTouchUpInside];
			btn_addTyke.tag = 13;
			btn_addTyke.hidden = YES;
			[cell.contentView addSubview:btn_addTyke];
		}
		
		UILabel *lbl_Name = (UILabel*)[cell.contentView viewWithTag:11];
		UILabel *lbl_childAge = (UILabel *)[cell.contentView viewWithTag:12];
		UIButton *btn_addTyke = (UIButton *)[cell.contentView viewWithTag:13];

		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		btn_addTyke.hidden = YES;
		lbl_Name.text = @"";
		lbl_childAge.text = @"";
		
		if ([[self.dict_userData objectForKey:@"Kids"] count] == indexPath.row) {
			cell.accessoryType = UITableViewCellAccessoryNone;
			lbl_Name.frame = CGRectMake(15, 12, 200, 20);
			lbl_Name.text = @"Add More Tykes";
			btn_addTyke.hidden = NO;
			return cell;
		}
		
		if ([[[self.dict_userData objectForKey:@"Kids"] objectAtIndex:indexPath.row] objectForKey:@"firstName"] && [[[self.dict_userData objectForKey:@"Kids"] objectAtIndex:indexPath.row] objectForKey:@"lastName"]) {
			lbl_Name.text = [NSString stringWithFormat:@" %@ %@",[[[self.dict_userData objectForKey:@"Kids"] objectAtIndex:indexPath.row] objectForKey:@"firstName"],[[[self.dict_userData objectForKey:@"Kids"] objectAtIndex:indexPath.row] objectForKey:@"lastName"]];
		}
		
		if ([[[self.dict_userData objectForKey:@"Kids"] objectAtIndex:indexPath.row] objectForKey:@"DOB"]) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
			[formatter setDateFormat:@"yyyy-MM-dd"];
			lbl_childAge.text =  [NSString stringWithFormat:@"(%@)",getChildAgeFromDate([formatter dateFromString:[[[self.dict_userData objectForKey:@"Kids"] objectAtIndex:indexPath.row] objectForKey:@"DOB"]])];
			[formatter release];
		}
		if ([[[[self.dict_userData objectForKey:@"Kids"] objectAtIndex:indexPath.row] objectForKey:@"gender"] isEqualToString:@"M"]) {
			lbl_childAge.textColor = BoyBlueColor;
//			lbl_childAge.textColor = [UIColor colorWithRed:0.498 green:0.733 blue:0.831 alpha:1.0];
		}else {
			lbl_childAge.textColor =GirlPinkColor;
//			lbl_childAge.textColor = [UIColor colorWithRed:0.8784 green:0.0941 blue:0.7215 alpha:1.0];
		}

		if ([[[[self.dict_userData objectForKey:@"Kids"] objectAtIndex:indexPath.row] objectForKey:@"status"] isEqualToString:@"t"]) {
			lbl_Name.textColor = WannaHangColor;
		} else {
			lbl_Name.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
		}
		CGSize aSize = [lbl_Name.text sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(180, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
		lbl_Name.frame = CGRectMake(15, 12, aSize.width, aSize.height);
		aSize = [lbl_childAge.text sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(150, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
		lbl_childAge.frame = CGRectMake(lbl_Name.frame.origin.x+lbl_Name.frame.size.width+3, 12, aSize.width, aSize.height);
		
		return cell;
	}else if (section == 2) {
		NSString *spouseCell = @"spouseCell";
		cell = [tableView dequeueReusableCellWithIdentifier:spouseCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:spouseCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(10, 12, 200, 20)];
			lblFirstName.tag = 21; 
			[lblFirstName setTextColor:[UIColor colorWithRed:0.298 green:0.341 blue:0.420 alpha:1.0]];
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font = [UIFont fontWithName:@"helvetica Neue" size:17];
			lblFirstName.font = [UIFont boldSystemFontOfSize:17];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
			
//			UIButton *btn_removeSpouse = [UIButton buttonWithType:UIButtonTypeCustom];
//			[btn_removeSpouse setFrame:CGRectMake(180, 7, 75, 30)];
//			btn_removeSpouse.tag = 22;
//			[btn_removeSpouse setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_CommonRedDashboard")] forState:UIControlStateNormal];
//			[btn_removeSpouse addTarget:self action:@selector(removeSpouse:) forControlEvents:UIControlEventTouchUpInside];
//			[btn_removeSpouse setTitle:@"Remove" forState:UIControlStateNormal];
//			btn_removeSpouse.titleLabel.font = [UIFont boldSystemFontOfSize:15];
//			[cell.contentView addSubview:btn_removeSpouse];
		}
		UILabel *lblFirstName = (UILabel *)[cell.contentView viewWithTag:21];
//		UIButton *btn_removeSpouse = (UIButton *)[cell.contentView viewWithTag:22];
//		btn_removeSpouse.hidden = YES;
		lblFirstName.font = [UIFont boldSystemFontOfSize:17];
		
		if ([[[self.dict_userData objectForKey:@"spouseDetails"] allKeys] count]) {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
//			btn_removeSpouse.hidden = NO;
			lblFirstName.text = [[NSString stringWithFormat:@"Spouse: %@ %@", 
								  [[self.dict_userData objectForKey:@"spouseDetails"] objectForKey:@"firstName"],
								 [[self.dict_userData objectForKey:@"spouseDetails"] objectForKey:@"lastName"]] capitalizedString];
			lblFirstName.font = [UIFont boldSystemFontOfSize:15];
			
			CGSize size = [lblFirstName.text sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(185, FLT_MAX)];
			lblFirstName.frame = CGRectMake(lblFirstName.frame.origin.x, lblFirstName.frame.origin.x, size.width, lblFirstName.frame.size.height);

		}else {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			lblFirstName.text = @"Send Spouse Invitation";
		}
		return cell;	
	}else if (indexPath.section == 3) {
		NSString *buttonCell = @"buttonCell";
		cell = [tableView dequeueReusableCellWithIdentifier:buttonCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:buttonCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.frame = CGRectMake( -3, -1, 270, 45);
			[btn setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_DeleteAccount")] forState:UIControlStateNormal];
			[btn addTarget:self action:@selector(deleteAccount:) forControlEvents:UIControlEventTouchUpInside];
			[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
			[[btn titleLabel] setFont:[UIFont boldSystemFontOfSize:13]];
			btn.tag = 16;
			btn.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:btn];
		}
		return cell;
	}
	
	
	return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if ([indexPath section] == 0) {

		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		
		ParentsDetailViewController *parent = [[ParentsDetailViewController alloc] initWithNibName:@"ParentsDetailView" bundle:nil];
		parent.dict_userData = [self.dict_userData objectForKey:@"userDetails"];
		parent.prevContImage = currentImage;
		[self.navigationController pushViewController:parent animated:NO];
		[parent release];
	}
	else if(indexPath.section == 1) {
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		if (indexPath.row == [[self.dict_userData objectForKey:@"Kids"] count]) {
			UserRegStepTwo *userRegStepTwo = [[UserRegStepTwo alloc] initWithNibName:@"AddKidsInSettings" bundle:nil];
			userRegStepTwo.prevContImage = currentImage;
			[self.navigationController pushViewController:userRegStepTwo animated:NO];
			[userRegStepTwo release];
			
		}else {
			EditKidsDetailsViewController *kidDetails = [[EditKidsDetailsViewController alloc] initWithNibName:@"EditKidsDetailsViewController" bundle:nil];
			kidDetails.prevContImage = currentImage;
			kidDetails.dict_data = [[self.dict_userData objectForKey:@"Kids"] objectAtIndex:indexPath.row];
			kidDetails.child_id = [[[self.dict_userData objectForKey:@"Kids"] objectAtIndex:indexPath.row] objectForKey:@"id"];
			[self.navigationController pushViewController:kidDetails animated:NO];
			[kidDetails release];
			}
	}
	else if(indexPath.section == 2) {
		if (indexPath.row == 0) {
			if ([[[self.dict_userData objectForKey:@"spouseDetails"] allKeys] count]) {
				if ([[self.dict_userData objectForKey:@"spouseDetails"]objectForKey:@"emailAddress"]) {
//					UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"DeLink"
//																   message:@"Do you really want to delete your spouse's account ?" 
//																  delegate:self 
//														 cancelButtonTitle:@"Cancel" 
//														 otherButtonTitles:@"Ok",nil];
//					[alert show];
//					[alert setTag:300];
//					[alert release];
				}
			}else {
				UIImage *currentImage = [self captureScreen];
				[self pushingViewController:currentImage];
				SpouseInvitationViewController *spouse = [[SpouseInvitationViewController alloc] initWithNibName:@"SpouseInvitationViewController" bundle:nil];
				spouse.prevContImage = currentImage;
				[self.navigationController pushViewController:spouse animated:NO];
				[spouse release];
				
			}
		}
	}
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) removeSpouse : (id) sender {
	[DELEGATE addLoadingView:self.view];
	[api_tyke removeSecondaryPR:[[self.dict_userData objectForKey:@"spouseDetails"] objectForKey:@"email"]];
}
- (void) addTykes: (id) sender {

	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	UserRegStepTwo *userRegStepTwo = [[UserRegStepTwo alloc] initWithNibName:@"AddKidsInSettings" bundle:nil];
	userRegStepTwo.prevContImage = currentImage;
	[self.navigationController pushViewController:userRegStepTwo animated:NO];
	[userRegStepTwo release];
		
}
- (void) getUserProfileResponse : (NSData *)data {
	
	[DELEGATE removeLoadingView:[DELEGATE window]];
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		self.dict_userData = [response objectForKey:@"response"];
		[self.dict_userData writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"] atomically:NO];
		[self.theTableView reloadData];
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!"
													   message:[[response objectForKey:@"reason"] objectForKey:@"reasonStr"]
													  delegate:nil
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) deleteAccountResponse : (NSData *)data {
	[DELEGATE removeLoadingView:self.vi_main];
	NSDictionary *response = [[data stringValue] JSONValue];
	
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
													   message:@"We are sorry to see you go. Hope to see you again on TykeKnit soon." 
													  delegate:nil
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[DELEGATE logOutCurrentUser];
	}
}

- (void) removeSecondaryRRResponse : (NSData*)data {
	
	[DELEGATE removeLoadingView:self.vi_main];
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success"
													   message:@"You have successfully deleted your spouse's account"
													  delegate:nil
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[self.theTableView reloadData];
	}
	
}
- (void) noNetworkConnection {
	[DELEGATE removeLoadingView:self.vi_main];
}

- (void) failWithError : (NSError*) error {
	[DELEGATE removeLoadingView:self.vi_main];
}

- (void) requestCanceled {
	[DELEGATE removeLoadingView:self.vi_main];
}


- (void)dealloc {
    [super dealloc];
}

@end
