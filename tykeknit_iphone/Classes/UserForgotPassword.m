//
//  UserForgotPassword.m
//  TykeKnit
//
//  Created by Ver on 22/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserForgotPassword.h"
#import "Global.h"
#import "JSON.h"

@implementation UserForgotPassword
@synthesize theTableView,user_email,api_tyke;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad {
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Help"];
	
	UIButton *btn_Back = [DELEGATE getBackBarButton];
	[btn_Back addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_Back] autorelease];
	
	api_tyke = [[TykeKnitApi alloc] init];
	api_tyke.delegate = self;
	
	UILabel *lbl_info = [[UILabel alloc]initWithFrame:CGRectMake(20, 25, 280, 60)];
	lbl_info.numberOfLines = 0;
	[lbl_info setFont:[UIFont fontWithName:@"helvetica Neue" size:12]];
	[lbl_info setFont:[UIFont systemFontOfSize:12]];
	[lbl_info setTextColor:[UIColor darkGrayColor]];
	[lbl_info setBackgroundColor:[UIColor clearColor]];
	[lbl_info setText:@"Please provide the email address you used to register with TykeKnit and we will email your account credentials."];
	[self.vi_main addSubview:lbl_info];
	[lbl_info release];
	
	[self.theTableView setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"img_background")]] autorelease]];
	[self.view setBackgroundColor:[UIColor blackColor]];
    [super viewDidLoad];
}

- (void) backClicked : (id) sender {
	[self popViewController];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 2;//[self.dictTykeData count]*3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
		NSString *CellIdentifier = @"EmailCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UILabel *lbl_info = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 230, 50)];
			lbl_info.tag = 1;
			[lbl_info setFont:[UIFont fontWithName:@"helvetica Neue" size:12]];
			[lbl_info setTextColor:[UIColor darkGrayColor]];
			[lbl_info setBackgroundColor:[UIColor clearColor]];
			[lbl_info setNumberOfLines:0];
			[lbl_info setText:@"Please provide the email address you used to register with TykeKnit and we will email your account credentials."];
			[cell.contentView addSubview:lbl_info];
			[lbl_info release];
			
			UITextField *txt_email = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 250, 20)];
			txt_email.placeholder = @"Email";
			[txt_email addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			txt_email.autocapitalizationType = UITextAutocapitalizationTypeNone;
			[txt_email addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			txt_email.returnKeyType = UIReturnKeyDone;
			txt_email.autocorrectionType = UITextAutocorrectionTypeNo;
			txt_email.keyboardType = UIKeyboardTypeEmailAddress;
			txt_email.font = [UIFont systemFontOfSize:15];
			txt_email.tag = 2;
			[cell.contentView addSubview:txt_email];
			[txt_email release];
			
			UIButton *btn_Retrive = [UIButton buttonWithType:UIButtonTypeCustom];
			btn_Retrive.frame = CGRectMake(15, -5, 280, 47);
			[btn_Retrive setBackgroundImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"default_tykeknit_button.png")] forState:UIControlStateNormal];
			[btn_Retrive setTitle:@"Retrieve Password" forState:UIControlStateNormal];
			[btn_Retrive addTarget:self action:@selector(btn_RetreivePasswordPressed:) forControlEvents:UIControlEventTouchUpInside];
			btn_Retrive.titleLabel.font = [UIFont boldSystemFontOfSize:19];
			btn_Retrive.tag = 3;
			[cell.contentView addSubview:btn_Retrive];
		}

		UILabel *lbl_info = (UILabel *)[cell.contentView viewWithTag:1];
		UITextField *txt_email = (UITextField *)[cell.contentView viewWithTag:2];
		UIButton *btn_Retrive = (UIButton *)[cell.contentView viewWithTag:3];
		
		lbl_info.hidden = YES;
		txt_email.hidden = YES;
		btn_Retrive.hidden = YES;
	
		switch (indexPath.section) {
			case 0:
				txt_email.hidden = NO;
				self.theTableView.separatorColor = [UIColor grayColor];
				break;
			case 1:
				cell.backgroundColor = [UIColor clearColor];
			self.theTableView.separatorColor = [UIColor clearColor];
				btn_Retrive.hidden = NO;
			default:
				break;
		}
		return cell;
}
- (void) nextPressed : (id) sender {
	UITextField *txt_field = (UITextField *) sender; 
	[txt_field resignFirstResponder];
}
- (void) editingEnded : (id) sender {
	UITextField *txt_field = (UITextField *) sender; 
	[txt_field resignFirstResponder];
	//if (!self.user_email) {
	self.user_email = [[NSString alloc]initWithString:txt_field.text];
	//}
	
	if (isValidEmailAddress(self.user_email)) {
		self.user_email = txt_field.text;
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!"
													   message:@"Invalid Email Address"
													  delegate:nil 
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		self.user_email = @"";
	}


}
- (void) btn_RetreivePasswordPressed : (id) sender {
	if ([self.user_email length]) {
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke forgotPassword:self.user_email];
	}else {
		//alertview	
		
	}
}
- (void) forgotPasswordResponse : (NSData *) data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thank you" 
													   message:@"We have sent your account credentials to the email address you have registered with."
													  delegate:self cancelButtonTitle:@"Ok" 
											 otherButtonTitles:nil];
		[alert setTag:300];
		[alert show];
		[alert release];
		
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Sorry" 
													   message:@"Unable to find an account with this email address."
													  delegate:self cancelButtonTitle:@"Ok" 
											 otherButtonTitles:nil];
		[alert setTag:301];
		[alert show];
		[alert release];
	}
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 300) {
		[self popViewController];
	}
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
	[api_tyke cancelCurrentRequest];
	[self.user_email release];
	[api_tyke release];
    [super dealloc];
}


@end
