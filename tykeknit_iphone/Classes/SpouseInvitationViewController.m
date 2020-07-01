//
//  SpouseInvitationViewController.m
//  TykeKnit
//
//  Created by Ver on 24/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SpouseInvitationViewController.h"
#import "JSON.h"

@implementation SpouseInvitationViewController
@synthesize str_spouseEmail,theTableView;
- (void)viewDidLoad {
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn_back] autorelease];
	
	self.vi_main.backgroundColor = [UIColor darkTextColor];
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Profile"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];

	api = [[TykeKnitApi alloc]init];
	api.delegate = self;
	numberOfRows = 1;
	[super viewDidLoad];
	
}


- (void) backPressed : (id) sender {
	[self popViewController];
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 2;//[self.dictTykeData count]*3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 100;
	}
	
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 50)] autorelease];
	if(section == 0){
		
		UIImageView *img_info = [[UIImageView alloc]initWithFrame:CGRectMake(42, 23, 23, 23)];
		//	[img_info setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"spouse_info.png")]];
		[vi addSubview:img_info];
		[img_info release];
		
		UILabel *lbl_info = [[UILabel alloc]initWithFrame:CGRectMake(25, 25, 230, 70)];
		lbl_info.tag = 1;
		[lbl_info setFont:[UIFont fontWithName:@"helvetica Neue" size:14]];
		[lbl_info setTextColor:[UIColor darkGrayColor]];
		[lbl_info setFont:[UIFont systemFontOfSize:13]];
		[lbl_info setTextAlignment:UITextAlignmentLeft];
		[lbl_info setBackgroundColor:[UIColor clearColor]];
		[lbl_info setNumberOfLines:0];
		[lbl_info setText:@"Inviting your spouse will create a family account and allow them to jointly manage fun activities for your Tyke(s)."];
		[vi addSubview:lbl_info];
		[lbl_info release];

	}
	return vi;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *CellIdentifier = @"EmailCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.backgroundColor = [UIColor whiteColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
		
		UITextField *txt_email = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 250, 20)];
		txt_email.placeholder = @"Email";
		[txt_email addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
		txt_email.autocorrectionType = UITextAutocorrectionTypeNo;
		txt_email.autocapitalizationType = UITextAutocapitalizationTypeNone;
		[txt_email addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
		txt_email.returnKeyType = UIReturnKeyDone;
		txt_email.textColor = [UIColor darkGrayColor];
		txt_email.keyboardType = UIKeyboardTypeEmailAddress;
		txt_email.font = [UIFont systemFontOfSize:15];
		txt_email.tag = 2;
		[cell.contentView addSubview:txt_email];
		[txt_email release];
		
		UIButton *btn_Retrive = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_Retrive.frame = CGRectMake(-5, -2, 275, 44);
		[btn_Retrive setBackgroundImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_sendEmail.png")] forState:UIControlStateNormal];
//		[btn_Retrive setTitle:@"Send Email" forState:UIControlStateNormal];
		[btn_Retrive addTarget:self action:@selector(btn_sendEmailClicked:) forControlEvents:UIControlEventTouchUpInside];
		btn_Retrive.titleLabel.font = [UIFont boldSystemFontOfSize:17];
		btn_Retrive.tag = 3;
		[cell.contentView addSubview:btn_Retrive];
	}
	
	UITextField *txt_email = (UITextField *)[cell.contentView viewWithTag:2];
	UIButton *btn_Retrive = (UIButton *)[cell.contentView viewWithTag:3];
	
	txt_email.hidden = YES;
	btn_Retrive.hidden = YES;
	
	switch (indexPath.section) {
		case 0:
			txt_email.hidden = NO;
			break;
		case 1:
			btn_Retrive.hidden = NO;
		default:
			break;
	}
	return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (void) nextPressed : (id) sender {
	UITextField *txt_field = (UITextField *) sender; 
	[txt_field resignFirstResponder];
}
- (void) editingEnded : (id) sender {
	UITextField *txt_field = (UITextField *) sender; 
	[txt_field resignFirstResponder];
	self.str_spouseEmail = [[NSString alloc]initWithString:txt_field.text];

	if (isValidEmailAddress(self.str_spouseEmail)) {
		self.str_spouseEmail = txt_field.text;
	}
}

- (void) btn_sendEmailClicked: (id) sender {
	[self.view endEditing:YES];
	if (isValidEmailAddress(self.str_spouseEmail)) {
		[DELEGATE addLoadingView:[DELEGATE window]];
		[api addSecondaryPR:self.str_spouseEmail];
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!"
													   message:@"Invalid Email Address"
													  delegate:nil 
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		self.str_spouseEmail = @"";
	}
	
	
}

- (void) addSecondaryRRResponse : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thanks!"
													   message:@"Invitation sent successfully."
													  delegate:nil 
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		self.str_spouseEmail = @"";
	}
	[DELEGATE removeLoadingView:[DELEGATE window]];
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
