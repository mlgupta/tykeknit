    //
//  PrivacyOptionsViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 16/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "PrivacyOptionsViewController.h"
#import "JSON.h"
#import "Global.h"

@implementation PrivacyOptionsViewController

@synthesize theTableView, dict_settingsOption, currentKey,api_tyke;

- (void) backPressed : (id) sender {
	
	[self.dict_settingsOption writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
	[self popViewController];
}

- (void) viewWillDisappear:(BOOL)animated {
	[self.dict_settingsOption writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];
	[super viewWillDisappear:animated];
}

- (void) viewDidLoad {
	
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	[btn_done addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_done] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Privacy Settings"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];
	
	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate = self;
	[super viewDidLoad];
}
- (void) doneClicked : (id) sender {
	
	[DELEGATE addLoadingView:[DELEGATE window]];
	[api_tyke updateSettings:[self.dict_settingsOption objectForKey:@"viewProfileOpt"]
			   whoCanContact:[self.dict_settingsOption objectForKey:@"contactOpt"]
		 memberNotifications:[self.dict_settingsOption objectForKey:@"membershipRequest"]
	   playDateNotifications:[self.dict_settingsOption objectForKey:@"playdate"]
playdateMessageNotifications:[self.dict_settingsOption objectForKey:@"messageBoard"]
 generalMessageNotifications:[self.dict_settingsOption objectForKey:@"generalMessages"]
			locationSettings:[self.dict_settingsOption objectForKey:@"currnetLocAsDefault"]];
	
}

#pragma mark -
#pragma mark UITableViewDelagate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	int rowIndex = [indexPath row];
	NSString *optionInfoCell = @"optionInfoCell";
	cell = [tableView dequeueReusableCellWithIdentifier:optionInfoCell];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:optionInfoCell] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
		UILabel *lbl_option = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, 230, 40)];
		lbl_option.tag = 16;
		lbl_option.font = [UIFont boldSystemFontOfSize:12];
		[cell.contentView addSubview:lbl_option];
		[lbl_option release];
	}
	
	UILabel *lbl_option = (UILabel*)[cell viewWithTag:16];
	switch (rowIndex) {
		case 0:{
			lbl_option.text = @"Friends";
			break;
		}
		case 1:{
			lbl_option.text = @"Friends & Friends of Friends";
			break;
		}
		case 2:{
			lbl_option.text = @"All";
			break;
		}
		default:
			break;
	}
	
	if ([[self.dict_settingsOption objectForKey:self.currentKey] intValue] == rowIndex+1) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	
	return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return 3;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	[self.dict_settingsOption setObject:[NSString stringWithFormat:@"%d", indexPath.row+1] forKey:self.currentKey];
	[self.theTableView reloadData];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
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
