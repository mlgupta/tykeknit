    //
//  NotificationsViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 08/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "NotificationsViewController.h"
#import "JSON.h"
#import "Global.h"

@implementation NotificationsViewController
@synthesize theTableView, dict_settings,api_tyke;

- (void) switchChanged : (id) sender {
	
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

- (void) backPressed : (id) sender {
	
	[self.dict_settings writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
	[self popViewController];
}

- (void) viewWillDisappear:(BOOL)animated {
	[self.dict_settings writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
	[super viewWillDisappear:animated];
}

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
- (void) viewDidLoad {
	
	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	[btn_done addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_done] autorelease];
	
	
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Notification"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];
	[self.navigationItem setHidesBackButton:YES];
	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate = self;
	
	self.dict_settings = [DELEGATE dict_settings];
	[self.theTableView reloadData];
	
	[super viewDidLoad];
}

- (void) doneClicked : (id) sender {
	
	for (NSString *key in [self.dict_settings allKeys]) {
	}
	
	[DELEGATE addLoadingView:[DELEGATE window]];
	[api_tyke updateSettings:[self.dict_settings objectForKey:@"viewProfileOpt"]
			   whoCanContact:[self.dict_settings objectForKey:@"contactOpt"]
		 memberNotifications:[self.dict_settings objectForKey:@"membershipRequest"]
	   playDateNotifications:[self.dict_settings objectForKey:@"playdate"]
playdateMessageNotifications:[self.dict_settings objectForKey:@"messageBoard"]
 generalMessageNotifications:[self.dict_settings objectForKey:@"generalMessages"]
			locationSettings:[self.dict_settings objectForKey:@"currnetLocAsDefault"]];
	
}

#pragma mark -
#pragma mark UITableViewDelagate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 50)] autorelease];
	
	UILabel *headerName = [[UILabel alloc] initWithFrame:CGRectMake(26, 23, 250, 20)];
	headerName.textAlignment = UITextAlignmentLeft;
	headerName.numberOfLines = 0;
	headerName.textColor =  [UIColor darkGrayColor];
	headerName.text = @"Manage your email notifications preferences.";
	[headerName setBackgroundColor:tableBackgroundColor];
	[headerName setTextColor:blueTextColor];
	[headerName setShadowColor:[UIColor whiteColor]];
	[headerName setShadowOffset:CGSizeMake(0, 1)];
	[headerName setFont:[UIFont fontWithName:@"helvetica Neue Thin" size:12]];
	[headerName setFont:[UIFont systemFontOfSize:12]];
	headerName.backgroundColor = [UIColor clearColor];
	[vi addSubview:headerName];
	[headerName release];
	
	return vi;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell;
	int rowIndex = [indexPath row];
	NSString *locationInfoCell = @"locationInfoCell";
	cell = [tableView dequeueReusableCellWithIdentifier:locationInfoCell];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:locationInfoCell] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
		
		UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 44)];
		lblFirstName.numberOfLines = 2;
		lblFirstName.tag = 16;
		lblFirstName.backgroundColor = [UIColor clearColor];
		lblFirstName.textColor = [UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];
		lblFirstName.font = [UIFont systemFontOfSize:16];
		[cell.contentView addSubview:lblFirstName];
		[lblFirstName release];
		
		UISwitch *sw_ONOFF = [[UISwitch alloc] initWithFrame:CGRectMake( 160, 8.5, 94, 27)];
		[sw_ONOFF addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		sw_ONOFF.tag = 17;
		[cell.contentView addSubview:sw_ONOFF];
		[sw_ONOFF release];
	}
	
	UISwitch *sw_OPT = (UISwitch*)[cell viewWithTag:17];
	UILabel *lbl_Name = (UILabel*)[cell viewWithTag:16];
	
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
	return cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	return 4;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
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
		[self.dict_settings setObject:[NSString stringWithFormat:@"%d",1] forKey:@"viewProfileOpt"];		
		[self.dict_settings writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
		[theTableView reloadData];
	}

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
