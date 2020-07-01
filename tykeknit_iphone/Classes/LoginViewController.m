//
//  LoginViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 02/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "LoginViewController.h"
#import "UserForgotPassword.h"
#import "userAuthentication.h"
#import "Global.h"
#import "JSON.h"
#import "Messages.h"
#import "UserRegStepOne.h"

@implementation LoginViewController
@synthesize theTableView, dict_loginInfo,rightSideView;

- (void) viewWillAppear:(BOOL)animated {
	
	//[self.navigationController setNavigationBarHidden:NO animated:YES];
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[super viewWillAppear:animated];
}

- (void) viewDidLoad {
	
	api_tyke = [[TykeKnitApi alloc] init];
	api_tyke.delegate = self;
	
	self.dict_loginInfo = [[NSMutableDictionary alloc] init];
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Login"];
	
	//shadow for Navigationbar
	CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.5f].CGColor;
	CGColorRef lightColor = [UIColor clearColor].CGColor;
	
	CAGradientLayer *newShadow = [[[CAGradientLayer alloc] init] autorelease];
	newShadow.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.width, 7);
	newShadow.colors = [NSArray arrayWithObjects:(id)darkColor, (id)lightColor, nil];
	[self.navigationController.navigationBar.layer addSublayer:newShadow];	
	self.navigationController.navigationBar.hidden = YES;
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.rightSideView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 0, 45, 418)];
	[self.rightSideView setBackgroundColor:[UIColor clearColor]];
	[self.rightSideView setImage:[[UIImage imageNamed:@"tab_grad.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:22]];
	[self.rightSideView setAlpha:1.0];
	[self.view addSubview:self.rightSideView];
	[self.rightSideView release];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	[self.theTableView setBackgroundColor:[UIColor clearColor]];
	
	UIButton *btn_default = [DELEGATE getDefaultBarButtonWithTitle:@"Cancel"];
	[btn_default addTarget:self action:@selector(cancelLoginClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_default] autorelease];
	self.navigationItem.leftBarButtonItem.enabled = NO;
	self.navigationItem.rightBarButtonItem = nil;
	[super viewDidLoad];
}

- (void) funJoinNow : (id) sender{
		self.navigationController.navigationBar.hidden = NO;
		[self.navigationController setNavigationBarHidden:YES animated:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Thanks" 
													message:@"I have read, and accept, TykeKnit's terms and conditions at www.tykeknit.com/terms and the privacy policy at www.tykeknit.com/privacy." 
												   delegate:self 
										  cancelButtonTitle:@"Decline" 
										  otherButtonTitles:@"Accept",nil];
	[alert setTag:301];
	[alert show];
	[alert release];
	
}

- (void) btn_ForgotPasswordPressed : (id) sender {
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	
	UserForgotPassword *forgot = [[UserForgotPassword alloc]initWithNibName:@"UserForgotPassword" bundle:nil];
	forgot.prevContImage = currentImage;
	[self.navigationController pushViewController:forgot animated:NO];
	[forgot release];
	
}
- (void) cancelLoginClicked : (id) sender {
	UITableViewCell *cell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];	
	[(UITextField *)[cell.contentView viewWithTag:1] setText:@""];
	[(UITextField *)[cell.contentView viewWithTag:1] resignFirstResponder];
	UITableViewCell *cell1 = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
	[(UITextField *)[cell1.contentView viewWithTag:1] setText:@""];
	[(UITextField *)[cell1.contentView viewWithTag:1] resignFirstResponder];
}

- (void) btn_LoginPressed : (id) sender {
	
//	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"]];

	if ([[self.dict_loginInfo objectForKey:@"user_name"] length] && [[self.dict_loginInfo objectForKey:@"password"] length] && isValidEmailAddress([self.dict_loginInfo objectForKey:@"user_name"])) {
		
		[DELEGATE addLoadingView:[DELEGATE window]];
        
		[api_tyke userLogin:[self.dict_loginInfo objectForKey:@"user_name"] txtPassword:[self.dict_loginInfo objectForKey:@"password"] txtDToken:[DELEGATE apnDeviceID]];
	}else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
														message:MSG_ERROR_VALID_USERNAME 
													   delegate:nil 
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) nextPressed : (id) sender {
	
	UITextField *txt_Field = (UITextField *)sender;
	[txt_Field resignFirstResponder];
	UITableViewCell *cell = (UITableViewCell *)[[txt_Field superview] superview];
	if (cell.tag == 0) {
		UITableViewCell *nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
		
		if (nextCell) {
			[(UITextField *)[nextCell.contentView viewWithTag:1] becomeFirstResponder];
		}
	}
}

- (void) editingStart : (id) sender {
	
	UITextField *txt_field = (UITextField *)sender;
	[txt_field selectAll:self];
	if ([txt_field isSecureTextEntry]) {
		txt_field.selected = YES;
		txt_field.highlighted = YES;
	}
	self.navigationItem.leftBarButtonItem.enabled = YES;
}

- (void) editingEnded : (id) sender {
	
	UITextField *txt_field = (UITextField*)sender;
	UITableViewCell *cell = (UITableViewCell *)[[txt_field superview] superview];
	if (cell.tag == 0) {
		[self.dict_loginInfo setObject:DefaultStringValue(txt_field.text) forKey:@"user_name"];
	}else if (cell.tag == 1) {
		[self.dict_loginInfo setObject:DefaultStringValue(txt_field.text) forKey:@"password"];
	}
	self.navigationItem.leftBarButtonItem.enabled = NO;
}


#pragma mark -
#pragma mark UITableViewDelagate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	
	int rowInd = [indexPath row];
	NSString *cellIdentifier = @"normalCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		UITextField *txtFirstName = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 20)];
		txtFirstName.tag = 1;
		[txtFirstName addTarget:self action:@selector(editingStart:) forControlEvents:UIControlEventEditingDidBegin];
		[txtFirstName addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
		[txtFirstName addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
		txtFirstName.autocorrectionType = UITextAutocorrectionTypeNo;
		txtFirstName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[txtFirstName setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		txtFirstName.font = [UIFont fontWithName:@"helvetica Neue" size:16];
		txtFirstName.backgroundColor = [UIColor clearColor];
		[txtFirstName setKeyboardType:UIKeyboardTypeAlphabet];
		[cell.contentView addSubview:txtFirstName];               
		[txtFirstName release];
	}
	
	UITextField *txt_Name = (UITextField*)[cell.contentView viewWithTag:1];
	
	if (rowInd == 0) {
		
		txt_Name.placeholder = @"Email";
		txt_Name.keyboardType = UIKeyboardTypeEmailAddress;
		txt_Name.returnKeyType = UIReturnKeyNext;
		txt_Name.secureTextEntry = NO;
	}else {
		
		txt_Name.placeholder = @"Password";
		txt_Name.clearButtonMode = UITextFieldViewModeAlways;
		txt_Name.returnKeyType = UIReturnKeyNext;
		txt_Name.secureTextEntry = YES;
	}
	
	cell.tag = rowInd;
	return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[self.theTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark Tyke Api Delegate

- (void) logInResponce : (NSData*) data {
	
	BOOL success  = NO;
	NSDictionary *response = [[data stringValue] JSONValue];
	NSLog(@"response : %@",response);
	
	if ([response objectForKey:@"responseStatus"]) {
		if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
			[self.dict_loginInfo setObject:[response objectForKey:@"response"] forKey:@"response"];
			[self.dict_loginInfo setObject:[[response objectForKey:@"response"] objectForKey:@"sessionID"] forKey:@"sessionID"];
			success = YES;
		}
	}
	
	if (success) {
		if ([[[self.dict_loginInfo objectForKey:@"response"] objectForKey:@"AccountConfirmationFlag"] intValue]) {
			[api_tyke getUserSettings];
		}else {
			if ([[[response objectForKey:@"response"] objectForKey:@"AccountDaysEff"] intValue] > 7) {
				[DELEGATE removeLoadingView:[DELEGATE window]];
				[self.navigationController setNavigationBarHidden:NO animated:YES];
				UIImage *currentImage = [self captureScreen];
				[self pushingViewController:currentImage];
				
				userAuthentication *user = [[userAuthentication alloc] initWithNibName:@"userAuthentication" bundle:nil];
				user.dict_loginInfo = self.dict_loginInfo;
				user.prevContImage = currentImage;
				[self.navigationController pushViewController:user animated:NO];
				[user release];
			}else {
				[api_tyke getUserSettings];
			}
		}
	}else {
		if( [[response objectForKey:@"responseStatus"] isEqualToString:@"failure"] ) {
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Request Failed!" 
															message:[[response objectForKey:@"response"] objectForKey:@"reasonStr"] 
														   delegate:nil
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
			[alert show];
			[alert release];		
		}
		
		[DELEGATE removeLoadingView:[DELEGATE window]];
	}

}
/*		[DELEGATE removeLoadingView:self.vi_main];
		if ([[response objectForKey:@"response"] objectForKey:@"AccountConfirmationFlag"]) {
			if (![[[response objectForKey:@"response"] objectForKey:@"AccountConfirmationFlag"] intValue]) {
				UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
																   message:@"Please confirm your account by clicking on confirmation link sent to your EmailId."// MSG_ERROR_VALID_REGISTER4
																  delegate:nil 
														 cancelButtonTitle:@"Ok" 
														 otherButtonTitles:nil];
				[objAlert show];
				[objAlert release];
			}
		}else {
			UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
															   message:[[response objectForKey:@"response"] objectForKey:@"reasonStr"]// MSG_ERROR_VALID_REGISTER4
															  delegate:nil 
													 cancelButtonTitle:@"Ok" 
													 otherButtonTitles:nil];
			[objAlert show];
			[objAlert release];
		}*/

- (void) getUserSettingsResponse : (NSData *)data {
	
	[DELEGATE removeLoadingView:[DELEGATE window]];
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		
//		[[DELEGATE dict_settings] setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"boolUserLocationCurrentLocationSetting"] intValue]] forKey:@"currnetLocAsDefault"];
		[[DELEGATE dict_settings] setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"boolUserNotificationGeneralMessages"] intValue]] forKey:@"generalMessages"];
		[[DELEGATE dict_settings] setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"boolUserNotificationMembershipRequest"] intValue]] forKey:@"membershipRequest"];
		[[DELEGATE dict_settings] setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"boolUserNotificationPlaydate"] intValue]] forKey:@"playdate"];
		[[DELEGATE dict_settings] setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"boolUserNotificationPlaydateMessageBoard"] intValue]] forKey:@"messageBoard"];
		[[DELEGATE dict_settings] setObject:[NSString stringWithFormat:@"%d",[[[response objectForKey:@"response"] objectForKey:@"txtUserContactSetting"]intValue]] forKey:@"contactOpt"];
		[[DELEGATE dict_settings] setObject:[NSString stringWithFormat:@"%d",1] forKey:@"viewProfileOpt"];		
		[[DELEGATE dict_settings] writeToFile:[DOC_DIR stringByAppendingPathComponent:@"settings.plist"] atomically:NO];

/*		
		if ([[[DELEGATE dict_settings] objectForKey:@"currnetLocAsDefault"] intValue]) {
			[DELEGATE switchLocationManagerOn:NO];
		}else {
			[DELEGATE switchLocationManagerOn:YES];
		}

*/ 
        [DELEGATE switchLocationManagerOn:YES];
		[DELEGATE userLoggedInWithDict:self.dict_loginInfo];
	}
}

- (void) MarkUserPosResponse : (NSData *) data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		[DELEGATE userLoggedInWithDict:self.dict_loginInfo];
	}
}	
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag == 300) {
		[DELEGATE cannotBeAbleToLogin];
	}else if (alertView.tag == 301) {
		if (buttonIndex == 1) {
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			
			UserRegStepOne *userRegStepOne = [[UserRegStepOne alloc] initWithNibName:@"UserRegStepOne" bundle:nil];
			userRegStepOne.prevContImage = currentImage;
			[self.navigationController pushViewController:userRegStepOne animated:NO];
			[userRegStepOne release];
		}
	}
}			
- (void) noNetworkConnection {
	
	[DELEGATE removeLoadingView:[DELEGATE window]];
}

- (void) failWithError : (NSError*) error {
	
	[DELEGATE removeLoadingView:[DELEGATE window]];
}

- (void) requestCanceled {
	
	[DELEGATE removeLoadingView:[DELEGATE window]];
}

- (void)dealloc {
	
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
	[self.dict_loginInfo release];
	[self.theTableView release];
    [super dealloc];
}


@end
