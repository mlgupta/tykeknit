//
//  LocationSettingsViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 08/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "LocationSettingsViewController.h"
#import "Global.h"
#import "JSON.h"

@implementation LocationSettingsViewController
@synthesize theTableView, dict_settings,api_tyke;

- (void) switchChanged : (id) sender {
	
	NSString *strVal = @"0";
	UISwitch *sw = (UISwitch *) sender;
	if (sw.on) {
		strVal = @"1";
	}else {
	}
	[self.dict_settings setObject:strVal forKey:@"currnetLocAsDefault"];
}

- (void) backPressed : (id) sender {
	
	[self.dict_settings writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
	[self popViewController];
}
- (void) viewWillDisappear:(BOOL)animated {
	[self.dict_settings writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
	[super viewWillDisappear:animated];
}

- (void) viewDidLoad {
	
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];

	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	[btn_done addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_done] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Location"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];
	
	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate = self;
	self.dict_settings = [DELEGATE dict_settings];
	
	[self.theTableView reloadData];
	[super viewDidLoad];
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

#pragma mark -
#pragma mark UITableViewDelagate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 110;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 90)] autorelease];
	
	UILabel *headerName = [[UILabel alloc] initWithFrame:CGRectMake(26, 18, 250, 90)];
	headerName.textAlignment = UITextAlignmentLeft;
	headerName.numberOfLines = 0;
	headerName.text = @"Prefer not to use your real time location? Turn this on to allow us to determine the approximate location based on your zip code. Please note that this applies to our users based in USA only.";
	[headerName setFont:[UIFont fontWithName:@"helvetica Neue Thin" size:12]];
	[headerName setFont:[UIFont systemFontOfSize:12]];
	[headerName setShadowColor:[UIColor whiteColor]];
	[headerName setLineBreakMode:UILineBreakModeWordWrap];
	[headerName setShadowOffset:CGSizeMake(0, 1)];
	[headerName setBackgroundColor:tableBackgroundColor];
	[headerName setTextColor:blueTextColor];
	[vi addSubview:headerName];
	[headerName release];
	return vi;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	
	NSString *locationInfoCell = @"locationInfoCell";
	cell = [tableView dequeueReusableCellWithIdentifier:locationInfoCell];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:locationInfoCell] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
		
		UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 20)];
		lblFirstName.numberOfLines = 2;
		lblFirstName.tag = 16;
		lblFirstName.textColor =[UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];		
		lblFirstName.backgroundColor = [UIColor clearColor];
		lblFirstName.font = [UIFont systemFontOfSize:16];
		[cell.contentView addSubview:lblFirstName];
		[lblFirstName release];
		
		UISwitch *sw_ONOFF = [[UISwitch alloc] initWithFrame:CGRectMake( 160, 7, 94, 27)];
		[sw_ONOFF addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
		sw_ONOFF.tag = 17;
		[cell.contentView addSubview:sw_ONOFF];
		[sw_ONOFF release];
	}
	
	UISwitch *sw_OPT = (UISwitch*)[cell viewWithTag:17];
	UILabel *lbl_Name = (UILabel*)[cell viewWithTag:16];
	
	lbl_Name.text = @"Zip Code Locator ";
	if ([[self.dict_settings objectForKey:@"currnetLocAsDefault"] intValue]) {
		sw_OPT.on = YES;
	}else {
		sw_OPT.on = NO;
	}
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 40;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	return 1;
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
		if ([[self.dict_settings objectForKey:@"currnetLocAsDefault"] intValue]) {
			[DELEGATE switchLocationManagerOn:NO];
		}else {
			[DELEGATE switchLocationManagerOn:YES];
		}

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
