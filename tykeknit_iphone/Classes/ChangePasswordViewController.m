//
//  ChangePasswordViewController.m
//  TykeKnit
//
//  Created by Ver on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChangePasswordViewController.h"
#import "Global.h"
#import "JSON.h"

@implementation ChangePasswordViewController
@synthesize theTableView,dict_userData;

- (void) doneClicked : (id) sender {
	[self.view endEditing:YES];
	BOOL flag = YES;
	NSString *strError = nil;
	if ([self.dict_userData objectForKey:@"oldPassword"]) {
		if (![[self.dict_userData objectForKey:@"oldPassword"] isEqualToString:[[DELEGATE dict_userInfo] objectForKey:@"password"]]) {
			flag = NO;
			strError = @"Password is incorrect";
		}	
		if (![[self.dict_userData objectForKey:@"newPassword"] isEqualToString:[self.dict_userData objectForKey:@"newPasswordAgain"]]) {
			flag = NO;
			strError = @"Please enter new password again.";
		}
	}else {
		flag = NO;
		strError = @"Please enter your old password";
	}
	
	
	if (!flag) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Password!"
													   message:strError
													  delegate:self 
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	if (flag) {
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke updateUserProfile:[self.dict_userData objectForKey:@"firstName"]
						txtLastName:[self.dict_userData objectForKey:@"lastName"]
						txtPassword:[self.dict_userData objectForKey:@"newPassword"]
							 txtDOB:[self.dict_userData objectForKey:@"dob"]
							imgFile:[self.dict_userData objectForKey:@"imgFile"]
					  txtParentType:[self.dict_userData objectForKey:@"gender"]
						 txtZipCode:[self.dict_userData objectForKey:@"zipcode"]];
	}
}

- (void) backPressed : (id) sender {
	
		[self popViewController];
}

- (void)viewDidLoad {
	
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	[btn_done addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_done] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Change Password"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];

	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate = self;
    [super viewDidLoad];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (section == 0) {
		return 3;
	}
	return 1;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	//	UITableViewCell *cell;
	
	int sectionInd = [indexPath section];
//	int rowIndex = [indexPath row];
	
	UITableViewCell *cell;
	if (sectionInd == 0) {
		NSString *parentInfo = @"parentInfo";
		cell = [tableView dequeueReusableCellWithIdentifier:parentInfo];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:parentInfo] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			UILabel *lblProfileField = [[UILabel alloc] initWithFrame:CGRectMake(20, 4, 127, 30)];
			lblProfileField.textAlignment = UITextAlignmentLeft;
			lblProfileField.tag = 1001;
			lblProfileField.textColor = [UIColor darkGrayColor];
			lblProfileField.backgroundColor = [UIColor clearColor];
			lblProfileField.font = [UIFont boldSystemFontOfSize:15];
			[cell.contentView addSubview:lblProfileField];
			[lblProfileField release];
			
			UITextField *txt_email = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 108, 20)];
			txt_email.userInteractionEnabled = YES;
			txt_email.placeholder = @"Password";
			txt_email.textAlignment = UITextAlignmentLeft;
			txt_email.textColor =[UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];
			[txt_email addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[txt_email addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			txt_email.secureTextEntry = YES;
			txt_email.autocorrectionType = UITextAutocorrectionTypeNo;
			txt_email.tag = 1002;
			txt_email.backgroundColor = [UIColor clearColor];
			txt_email.font = [UIFont systemFontOfSize:14];
			[cell.contentView addSubview:txt_email];
			[txt_email release];
			
		}
		UITextField *txt_email = (UITextField *)[cell.contentView viewWithTag:1002];
		UILabel *lblProfileField = (UILabel *)[cell.contentView viewWithTag:1001];

		switch (indexPath.row) {
			case 0:
				lblProfileField.text = @"Old:";
				break;
			case 1:
				lblProfileField.text = @"New:";
				break;
			case 2:
				lblProfileField.text =@"Again:";
				[txt_email setFrame:CGRectMake(100, 10, 108, 20)];
				break;
			default:
				break;
		}
			cell.tag = indexPath.row;
		return cell;
	}else if (sectionInd ==1) {
		NSString *parentInfo = @"parentInfo";
		cell = [tableView dequeueReusableCellWithIdentifier:parentInfo];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:parentInfo] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			UILabel *lblProfileField = [[UILabel alloc] initWithFrame:CGRectMake(75, 7, 127, 30)];
			lblProfileField.textAlignment = UITextAlignmentLeft;
			lblProfileField.tag = 1001;
			lblProfileField.text = @"Change Password";
			lblProfileField.textColor = [UIColor colorWithRed:0.298 green:0.341 blue:0.420 alpha:1.0];
			lblProfileField.backgroundColor = [UIColor clearColor];
			lblProfileField.font = [UIFont boldSystemFontOfSize:14];
			[cell.contentView addSubview:lblProfileField];
			[lblProfileField release];
			
		}
		cell.tag = indexPath.row;
		return cell;
	}
	return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section == 1) {
		BOOL flag = YES;
		NSString *strError = nil;
		if ([self.dict_userData objectForKey:@"oldPassword"]) {
			if (![[self.dict_userData objectForKey:@"oldPassword"] isEqualToString:[[DELEGATE dict_userInfo] objectForKey:@"password"]]) {
				flag = NO;
				strError = @"Password is incorrect.";
			}	
			if (![[self.dict_userData objectForKey:@"newPassword"] isEqualToString:[self.dict_userData objectForKey:@"newPasswordAgain"]]) {
				flag = NO;
				strError = @"Please enter new password again.";
			}
		}		
		
		if (!flag) {
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Password"
														   message:strError
														  delegate:self 
												 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
			
		}
		if (flag) {
			[DELEGATE addLoadingView:self.vi_main];
			[api_tyke updateUserProfile:[self.dict_userData objectForKey:@"firstName"] 
							txtLastName:[self.dict_userData objectForKey:@"lastName"]
							txtPassword:[self.dict_userData objectForKey:@"newPassword"]
								 txtDOB:[self.dict_userData objectForKey:@"dob"]
								imgFile:nil txtParentType:[self.dict_userData objectForKey:@"gender"] 
							 txtZipCode:[self.dict_userData objectForKey:@"zipcode"]];
		}
		
	}
}
-(void) nextPressed : (id) sender {
	UITextField *txt_field = (UITextField *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[txt_field superview] superview];

	if (cell.tag == 0) {
		UITableViewCell *nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
		[(UITextField *)[nextCell viewWithTag:1002] becomeFirstResponder];
	}else if(cell.tag == 1) {
		UITableViewCell *nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
		[(UITextField *)[nextCell viewWithTag:1002] becomeFirstResponder];

	}
	[txt_field resignFirstResponder];
}


- (void) editingEnded:(id)sender {
	UITextField *txt_field = (UITextField *)sender;
	NSString *value = txt_field.text;
	UITableViewCell *cell = (UITableViewCell *)[[txt_field superview] superview];
	if ([value length]) {
		switch (cell.tag) {
			case 0:
				[self.dict_userData setObject:DefaultStringValue(value)  forKey:@"oldPassword"];				
				break;
			case 1:
				[self.dict_userData setObject:DefaultStringValue(value) forKey:@"newPassword"];
				break;
			case 2:
				[self.dict_userData setObject:DefaultStringValue(value) forKey:@"newPasswordAgain"];
				break;
		}
	}
}


- (void) updateUserProfileResponse:(NSData *)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		NSMutableDictionary *userDetails = [DELEGATE getUserDetails];
		[userDetails setObject:self.dict_userData forKey:@"userDetails"];
		[userDetails writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"] atomically:NO];
		
		[[DELEGATE dict_userInfo] setObject:[self.dict_userData objectForKey:@"newPassword"] forKey:@"password"];
		[[DELEGATE dict_userInfo] writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userInfo.plist"] atomically:NO];
		[self popViewController];
	}
}
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}
    // Release any cached data, images, etc. that aren't in use.
- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
