    //
//  PrivacyViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 08/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "PrivacyViewController.h"
#import "PrivacyOptionsViewController.h"
#import "Global.h"
#import "JSON.h"

@implementation PrivacyViewController
@synthesize theTableView, dict_settings,api_tyke;

- (void) backPressed : (id) sender {
	[self popViewController];
}

- (void) viewWillDisappear:(BOOL)animated {
	[self.dict_settings writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
	[super viewWillDisappear:animated];
}
- (void) viewWillAppear:(BOOL)animated {
	
	[self.theTableView reloadData];

	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_settings3 aboveSubview:[DELEGATE vi_sideView].img_back];
//	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_settings_wannaHang belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_settings2 belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_settings1 belowSubview:[DELEGATE vi_sideView].img_back];
	
	[super viewWillAppear:animated];
}
- (void) doneClicked : (id) sender {
	
	[DELEGATE addLoadingView:[DELEGATE window]];
	[api_tyke updateSettings:[self.dict_settings objectForKey:@"viewProfileOpt"]
			   whoCanContact:[self.dict_settings objectForKey:@"contactOpt"]
		 memberNotifications:[self.dict_settings objectForKey:@"membershipRequest"]
	   playDateNotifications:[self.dict_settings objectForKey:@"playdate"]
playdateMessageNotifications:[self.dict_settings objectForKey:@"messageBoard"]
 generalMessageNotifications:[self.dict_settings objectForKey:@"generalMessages"]
			locationSettings:[self.dict_settings objectForKey:@"currnetLocAsDefault"]];
	
}

- (void) viewDidLoad {
	
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	[btn_done addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_done] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Settings"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];
	
	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate = self;

	self.dict_settings = [DELEGATE dict_settings];
	[self.theTableView reloadData];
	
	[super viewDidLoad];
}
- (void) selectionChanged : (id) sender {
	
	UIButton *btn_changed = (UIButton*)sender;
	UITableViewCell *cell = (UITableViewCell*)[[btn_changed superview] superview];
	
	NSString *currentKey = nil;
	if (cell.tag == 1) {
		currentKey = @"viewProfileOpt";
	}else if (cell.tag == 2) {
		currentKey = @"contactOpt";
	}
	
	NSString *strValue = nil;
	if (btn_changed.tag == 17) {
		strValue = @"0";
	}else if (btn_changed.tag == 18) {
		strValue = @"1";
	}else if (btn_changed.tag == 19) {
		strValue = @"2";
	}
	
	[self.dict_settings setObject:strValue forKey:currentKey];
	[self.theTableView reloadData];
}

- (void) segmentChanged : (id) sender {
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell = nil;
	int rowIndex = [indexPath row];
	NSString *locationInfoCell = @"locationInfoCell";
	
	cell = [tableView dequeueReusableCellWithIdentifier:locationInfoCell];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:locationInfoCell] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];

		UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 230, 15)];
		lblFirstName.tag = 16;
		lblFirstName.textColor =[UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];
		lblFirstName.font = [UIFont systemFontOfSize:13];
		[lblFirstName setBackgroundColor:[UIColor clearColor]];
		[cell.contentView addSubview:lblFirstName];
		[lblFirstName release];
		
		UISegmentedControl *seg_control = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"In-Knit",@"Extended-Knit",@"All",nil]];
		[seg_control setSegmentedControlStyle:UISegmentedControlStyleBar];
        [seg_control setTag:17];
	    [seg_control addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
		[seg_control setFrame:CGRectMake(10, 32, 240, 25)];
		[seg_control setWidth:70 forSegmentAtIndex:0];
		[seg_control setWidth:100 forSegmentAtIndex:1];
		[seg_control setWidth:70 forSegmentAtIndex:2];		
        [cell.contentView addSubview:seg_control];
	    [seg_control release];
	}
	
	UILabel *lbl_Name = (UILabel*)[cell.contentView viewWithTag:16];
	UISegmentedControl *seg_control = (UISegmentedControl*)[cell.contentView viewWithTag:17];
	
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

	
	return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 70;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void) updateSettingsResopnse : (NSData *)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:[DELEGATE window]];		
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		/* UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thank you"
													   message:@"Settings Saved"
													  delegate:nil
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release]; */
		[self.dict_settings writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!"
													   message:[[response objectForKey:@"reason"] objectForKey:@"reasonStr"]
													  delegate:nil
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
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
		//		[self.dict_settings setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"txtUserProfileSetting"] intValue]] forKey:@"viewProfileOpt"];	
		[self.dict_settings setObject:[NSString stringWithFormat:@"%d",1] forKey:@"viewProfileOpt"];		
		[self.dict_settings writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
		[theTableView reloadData];
	}
	
}

- (void)dealloc {
	
	[super dealloc];
}

@end
