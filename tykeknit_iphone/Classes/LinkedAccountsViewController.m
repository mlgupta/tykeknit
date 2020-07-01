    //
//  LinkedAccountsViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 08/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "LinkedAccountsViewController.h"
#import "Global.h"
#import "FacebookAPI.h"

@implementation LinkedAccountsViewController
@synthesize theTableView, dict_settings,api_facebook;

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
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Linked Accounts"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];
	
	api_facebook = [[FacebookAPI alloc]init];
	api_facebook.delegate = self;
	[super viewDidLoad];
}


#pragma mark -
#pragma mark UITableViewDelagate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return 100;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 90)] autorelease];
	
	UILabel *headerName = [[UILabel alloc] initWithFrame:CGRectMake(30, 3, 230, 90)];
	headerName.textAlignment = UITextAlignmentLeft;
	headerName.numberOfLines = 0;
	headerName.textColor =  [UIColor darkGrayColor];
	headerName.text = @"We do not store information about your contacts. Information you provide to add friends is only used to send invitations on your behalf.";
	[headerName setFont:[UIFont fontWithName:@"helvetica Neue Thin" size:12]];
	[headerName setFont:[UIFont boldSystemFontOfSize:12]];
	headerName.backgroundColor = [UIColor clearColor];
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
		
		UIImageView *img_facebook = [[UIImageView alloc] initWithFrame:CGRectMake(20, 9, 25, 25)];
		[img_facebook setImage:[UIImage imageNamed:@"img_inviteFriendsFacebook.png"]];
		[cell.contentView addSubview:img_facebook];
		[img_facebook release];
		
		UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(55, 0, 150, 44)];
		lblFirstName.numberOfLines = 2;
		lblFirstName.tag = 16;
		lblFirstName.textColor =[UIColor grayColor];		
		lblFirstName.backgroundColor = [UIColor clearColor];
		lblFirstName.font = [UIFont systemFontOfSize:15];
		[cell.contentView addSubview:lblFirstName];
		[lblFirstName release];
		
		UIButton *btn_connect = [UIButton buttonWithType:UIButtonTypeCustom];
		 [btn_connect setFrame:CGRectMake(160,9, 72, 30)];
		[btn_connect setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"facebook_connect")] forState:UIControlStateNormal];
		[btn_connect setTitle:@"Connect" forState:UIControlStateNormal];
		[btn_connect addTarget:self action:@selector(FBLogin:) forControlEvents:UIControlEventTouchUpInside];
		[btn_connect.titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
		[btn_connect setTag:17];
		[cell.contentView addSubview:btn_connect];
	}
	
	UIButton *btn_connect = (UIButton*)[cell viewWithTag:17];
	UILabel *lbl_Name = (UILabel*)[cell viewWithTag:16];
	
	lbl_Name.text = @"Facebook";
	
	if ([api_facebook isSessionValid]) {
		[self.dict_settings setObject:@"1" forKey:@"facebook"];
		[btn_connect setTitle:@"Disconnect" forState:UIControlStateNormal];
	}
	else 
	{
		[self.dict_settings setObject:@"0" forKey:@"facebook"];	
		[btn_connect setTitle:@"Connect" forState:UIControlStateNormal];
	}
	return cell;
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

- (void) FBLogin : (id) sender {
	
	if ([[self.dict_settings objectForKey:@"facebook"] isEqualToString:@"1"]) 		
		[api_facebook logout];
	else
		[api_facebook login];
}

- (void) facebookDidLogout {	
	[self.theTableView reloadData];

}
- (void) facebookDidLogin {
	[self.theTableView reloadData];
}


- (void)dealloc {
    [super dealloc];
}


@end
