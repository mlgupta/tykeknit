//
//  GeneralTabViewController.m
//  TykeKnit
//
//  Created by Ver on 23/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GeneralTabViewController.h"
#import "PrivacyViewController.h"
#import "NotificationsViewController.h"
#import "LinkedAccountsViewController.h"
#import "LocationSettingsViewController.h"
#import "Global.h"
#import "JSON.h"

@implementation GeneralTabViewController
@synthesize theTableView,dict_settings,isValueChanged;
- (void) viewWillAppear:(BOOL)animated {
	
	if ([[[DELEGATE window] subviews] containsObject:[DELEGATE nav_wannaHangBar].view]) {
		[[DELEGATE nav_wannaHangBar].view removeFromSuperview];
	}
	
	
	[self.theTableView reloadData];
	
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_settings3 aboveSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_settings_wannaHang belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_settings2 belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_settings1 belowSubview:[DELEGATE vi_sideView].img_back];
	
	[super viewWillAppear:animated];
}

- (void)viewDidLoad {
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Settings"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];
	[self.navigationItem setHidesBackButton:YES];
//	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
//	[btn_done addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
//	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_done] autorelease];

	self.isValueChanged = NO;
	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate = DELEGATE;
    [super viewDidLoad];
}

- (void) doneClicked : (id) sender {
	if (self.isValueChanged) {
        [api_tyke setDelegate:DELEGATE];
		[api_tyke updateSettings:[self.dict_settings objectForKey:@"viewProfileOpt"]
				   whoCanContact:[self.dict_settings objectForKey:@"contactOpt"]
			 memberNotifications:[self.dict_settings objectForKey:@"membershipRequest"]
		   playDateNotifications:[self.dict_settings objectForKey:@"playdate"]
	playdateMessageNotifications:[self.dict_settings objectForKey:@"messageBoard"]
	 generalMessageNotifications:[self.dict_settings objectForKey:@"generalMessages"]
				locationSettings:[self.dict_settings objectForKey:@"currnetLocAsDefault"]];
        [api_tyke autorelease];
	}
	
}

- (void) viewWillDisappear:(BOOL)animated {
    [self doneClicked:nil];
    [super viewWillDisappear:animated];
}

- (void) updateSettingsResopnse : (NSData *)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		if ([[self.dict_settings objectForKey:@"currnetLocAsDefault"] intValue]) {
			[DELEGATE switchLocationManagerOn:NO];
		}else {
			[DELEGATE switchLocationManagerOn:YES];
		}
		[self.dict_settings writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!"
													   message:[[response objectForKey:@"response"] objectForKey:@"reasonStr"]
													  delegate:nil
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	
}


- (void) switchChanged : (id) sender {

	self.isValueChanged = YES;
	NSString *strVal = @"0";
	UISwitch *sw = (UISwitch *) sender;
	if (sw.on) {
		strVal = @"1";
	}else {
	}
	[self.dict_settings setObject:strVal forKey:@"currnetLocAsDefault"];
}


- (void) NotificationSwitchChanged : (id) sender {

	self.isValueChanged = YES;
	NSString *strVal = @"0";
	UISwitch *sw = (UISwitch *) sender;
	if (sw.on) {
		strVal = @"1";
	}
	
	int cellTag = [(UITableViewCell *)[[(UISwitch*)sender superview] superview] tag];
	switch (cellTag) {
		case 1:
			[self.dict_settings setObject:strVal forKey:@"membershipRequest"];
			break;
		case 2:
			[self.dict_settings setObject:strVal forKey:@"playdate"];
			break;
		case 3:
			[self.dict_settings setObject:strVal forKey:@"messageBoard"];
			break;
		case 4:
			[self.dict_settings setObject:strVal forKey:@"generalMessages"];
			break;
		default:
			break;
	}
}

- (void) segmentChanged : (id) sender {
	self.isValueChanged = YES;
	UISegmentedControl *seg_control = (UISegmentedControl *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[seg_control superview] superview];
	int row = [self.theTableView indexPathForCell:cell].row;
	NSString *key = nil;
	if (row == 0) {
		key = @"viewProfileOpt";
	}else {
		key = @"contactOpt";
	}
	[self.dict_settings setObject:[NSString stringWithFormat:@"%d", seg_control.selectedSegmentIndex+1] forKey:key];
	[self.theTableView reloadData];
	
}

#pragma mark -
#pragma mark UITableViewDelagate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section ==1) {
		return 70;
	}
	if (section == 2) {
		return 125;
	}
	return 27;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 50)] autorelease];
	
	UILabel *header = [[UILabel alloc] initWithFrame:CGRectZero];
	UILabel *subHeader = [[UILabel alloc] initWithFrame:CGRectZero];
	
	header.frame = CGRectMake(20, 5, 250, 20);
    header.textColor = blueTextColor;
	header.font = [UIFont boldSystemFontOfSize:14];
	header.shadowOffset = CGSizeMake(0, 1);
    header.shadowColor = [UIColor whiteColor]; 
    header.backgroundColor = [UIColor clearColor];
	
	subHeader.backgroundColor = [UIColor clearColor];
	[subHeader setFont:[UIFont fontWithName:@"helvetica Neue Thin" size:12]];
	subHeader.font = [UIFont systemFontOfSize:12];
    subHeader.textColor = blueTextColor;
	
	if (section == 0) {
		header.text = @"View My Profile";
	}else if (section ==1) {
		header.text = @"Notifications";
		subHeader.frame = CGRectMake(20, 23, 220, 40);
		subHeader.numberOfLines = 2;
		subHeader.text = @"Manage your email notifications preferences.";
	}else if (section ==2) {
		header.text = @"Location";
		subHeader.frame = CGRectMake(20, 23, 250, 100);
		subHeader.textAlignment = UITextAlignmentLeft;
		subHeader.numberOfLines = 0;
		subHeader.text = @"Prefer not to use your real time location? Turn this on to allow us to determine the approximate location based on your zip code. Please note that this applies to our users based in USA only.";
	}

	[vi addSubview:subHeader];
	[subHeader release];
    [vi addSubview:header];
    [header release];
	return vi;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 44;			
	}else if (indexPath.section == 1) {
		return 44;
	}else if (indexPath.section == 2) {
		return 40;
	}
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell;
	int rowIndex = [indexPath row];
	int sectionIndex = [indexPath section];
	if (sectionIndex == 0) {
		NSString *locationInfoCell = @"PrivacyCell";
		cell = [tableView dequeueReusableCellWithIdentifier:locationInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:locationInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
//			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 15)];
//			lblFirstName.tag = 1;
//			lblFirstName.textColor =[UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];
//			lblFirstName.font = [UIFont systemFontOfSize:13];
//			[lblFirstName setBackgroundColor:[UIColor clearColor]];
//			[cell.contentView addSubview:lblFirstName];
//			[lblFirstName release];
			
			UISegmentedControl *seg_control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"In-Knit",@"Extended-Knit",@"All",nil]];
			[seg_control setSegmentedControlStyle:UISegmentedControlStyleBar];
			[seg_control setTag:2];
			[seg_control addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
			[seg_control setFrame:CGRectMake(10, 10, 240, 25)];
			[seg_control setWidth:70 forSegmentAtIndex:0];
			[seg_control setWidth:100 forSegmentAtIndex:1];
			[seg_control setWidth:70 forSegmentAtIndex:2];		
			[cell.contentView addSubview:seg_control];
			[seg_control release];
		}
		
		UILabel *lbl_Name = (UILabel*)[cell.contentView viewWithTag:1];
		UISegmentedControl *seg_control = (UISegmentedControl*)[cell.contentView viewWithTag:2];
		
		NSString *currentKey = nil;
		switch (rowIndex) {
			case 0:{
				currentKey = @"viewProfileOpt";
				lbl_Name.text = @"View My Profile";
				break;
			}
			case 1:{
				currentKey = @"contactOpt";
				lbl_Name.text = @"Contact Me";
				break;
			}
			default:
				break;
		}
		int option = [[self.dict_settings objectForKey:currentKey] intValue]-1;
		seg_control.selectedSegmentIndex = option;
		
	}else if (indexPath.section == 1) {
		NSString *locationInfoCell = @"Notification";
		cell = [tableView dequeueReusableCellWithIdentifier:locationInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:locationInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 44)];
			lblFirstName.numberOfLines = 2;
			lblFirstName.tag = 11;
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.textColor = [UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];
			lblFirstName.font = [UIFont systemFontOfSize:16];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
			
			UISwitch *sw_ONOFF = [[UISwitch alloc] initWithFrame:CGRectMake( 160, 8.5, 94, 27)];
			[sw_ONOFF addTarget:self action:@selector(NotificationSwitchChanged:) forControlEvents:UIControlEventValueChanged];
			sw_ONOFF.tag = 12;
			[cell.contentView addSubview:sw_ONOFF];
			[sw_ONOFF release];
		}
		
		UILabel *lbl_Name = (UILabel*)[cell.contentView viewWithTag:11];		
		UISwitch *sw_OPT = (UISwitch*)[cell.contentView viewWithTag:12];
		
		switch (rowIndex) {
			case 0:{
				lbl_Name.text = @"Knitroduction";
				if ([[self.dict_settings objectForKey:@"membershipRequest"] intValue]) {
					sw_OPT.on = YES;
				}else {
					sw_OPT.on = NO;
				}
			}
				break;
			case 1:{
				lbl_Name.text = @"Playdate";
				if ([[self.dict_settings objectForKey:@"playdate"] intValue]) {
					sw_OPT.on = YES;
				}else {
					sw_OPT.on = NO;
				}
				break;
			}
			case 2:{
				lbl_Name.text = @"TykeBoard";
				if ([[self.dict_settings objectForKey:@"messageBoard"] intValue]) {
					sw_OPT.on = YES;
				}else {
					sw_OPT.on = NO;
				}
				break;
			}
			case 3:{
				lbl_Name.text = @"General Message";
				if ([[self.dict_settings objectForKey:@"generalMessages"] intValue]) {
					sw_OPT.on = YES;
				}else {
					sw_OPT.on = NO;
				}
				break;
			}
			default:
				break;
		}
		
		cell.tag = rowIndex+1;
	}else if (indexPath.section == 2) {
		NSString *locationInfoCell = @"locationInfoCell";
		cell = [tableView dequeueReusableCellWithIdentifier:locationInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:locationInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 20)];
			lblFirstName.numberOfLines = 2;
			lblFirstName.tag = 21;
			lblFirstName.textColor =[UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];		
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font = [UIFont systemFontOfSize:16];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
			
			UISwitch *sw_ONOFF = [[UISwitch alloc] initWithFrame:CGRectMake( 160, 7, 94, 27)];
			[sw_ONOFF addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
			sw_ONOFF.tag = 22;
			[cell.contentView addSubview:sw_ONOFF];
			[sw_ONOFF release];
		}
		
		UISwitch *sw_OPT = (UISwitch*)[cell.contentView viewWithTag:22];
		UILabel *lbl_Name = (UILabel*)[cell.contentView viewWithTag:21];
		
		lbl_Name.text = @"Zip Code Locator ";
		if ([[self.dict_settings objectForKey:@"currnetLocAsDefault"] intValue]) {
			sw_OPT.on = YES;
		}else {
			sw_OPT.on = NO;
		}
	}		
	return cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
//	return 1;
	return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (section == 0 || section == 2) {
		return 1;
	}else if (section == 1) {
		return 4;
	}
	return 3;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	/*
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];

	if (indexPath.row == 0) {
		PrivacyViewController *privacy = [[PrivacyViewController alloc] initWithNibName:@"PrivacyView" bundle:nil];
		privacy.dict_settings = self.dict_settings;
		privacy.prevContImage = currentImage;
		[self.navigationController pushViewController:privacy animated:NO];
		[privacy release];
	}else if (indexPath.row == 1) {
		NotificationsViewController *notify = [[NotificationsViewController alloc] initWithNibName:@"NotificationsView" bundle:nil];
		notify.dict_settings = self.dict_settings;
		notify.prevContImage = currentImage;
		[self.navigationController pushViewController:notify animated:NO];
		[notify release];
	}else if (indexPath.row == 2) {
		LocationSettingsViewController *location = [[LocationSettingsViewController alloc] initWithNibName:@"LocationSettingsView" bundle:nil];
		location.dict_settings = self.dict_settings;
		location.prevContImage = currentImage;
		[self.navigationController pushViewController:location animated:NO];
		[location release];
	}
	 */
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
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
