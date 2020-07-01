//
//  UserRegStepOne.m
//  TykeKnit
//
//  Created by Abhinit Tiwari on 06/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#define NUMBERS @"0123456789"
#define NUMBERSPERIOD @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"


#import "UserRegStepOne.h"
#import "UserRegStepTwo.h"
#import "UserRegSpouseInfo.h"
#import "TermsAndCondView.h"
#import "TykeKnitLoginVC.h"
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "JSON.h"
#import "UIImage+Helpers.h"
#import "CustomTableViewCell.h"
#import "Messages.h"

@implementation UserRegStepOne
@synthesize regStepOneTV, btnImage,vi_photoShadow;
@synthesize dictParentsData,photoImageView,rightSideView;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 160;

#pragma mark -
#pragma mark UIViewController Methods

- (void)viewDidAppear:(BOOL)animated {
	
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[super viewDidAppear:animated];
}

- (void) viewDidLoad {
	
	isUserRegistered = NO;
	api_tyke = [[TykeKnitApi alloc] init];
	api_tyke.delegate = self;
	
	//	self.rightSideView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 0, 45, 418)];
	//	[self.rightSideView setBackgroundColor:[UIColor clearColor]];
	//	[self.rightSideView setImage:[[UIImage imageNamed:@"tab_grad.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:22]];
	//	[self.rightSideView setAlpha:1.0];
	//	[self.view addSubview:self.rightSideView];
	//	[self.rightSideView release];
	
	
	[self.regStepOneTV setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	[self.view setBackgroundColor:[UIColor blackColor]];
	
//	[self.regStepOneTV setBackgroundView:[[[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"registeration_background.png")]]autorelease]];
	[self.regStepOneTV setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"img_background")]] autorelease]];
	self.dictParentsData = [[NSMutableDictionary alloc] init];
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Parent Info"];
	
	UIButton *btn_default = [DELEGATE getDefaultBarButtonWithTitle:@"Cancel"];
	[btn_default addTarget:self action:@selector(cancelSignUpClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_default] autorelease];
	
	UIButton *btn_register = [DELEGATE getDefaultBarButtonWithTitle:@"Next"];
	[btn_register addTarget:self action:@selector(registerParents:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_register] autorelease];
	self.navigationItem.rightBarButtonItem.enabled = NO;

	animatedDistance = 0.0f;
	self.regStepOneTV.allowsSelection = NO;
	self.regStepOneTV.sectionFooterHeight = 0.0;
	self.regStepOneTV.sectionHeaderHeight = 0.0f;
	
	self.regStepOneTV.clipsToBounds = NO;
	[super viewDidLoad];
}

#pragma mark -

- (BOOL) isFormValid {
	
//	NSString *strError = nil;
	int Flag = 0;
	
	if(!([[self.dictParentsData objectForKey:@"txtFirstName"] length] > 0) ) {
//		strError = MSG_ERROR_VALID_NAME1;
		Flag = 1;
	}else if(!([[self.dictParentsData objectForKey:@"txtLastName"] length] > 0) ) {
//		strError = MSG_ERROR_VALID_NAME2;
		Flag = 1;
	}else if(!([[self.dictParentsData objectForKey:@"txtEmail"] length] > 0) ) {
//		strError = @"Please Enter Email";
		Flag = 1;
	}else if(!([[self.dictParentsData objectForKey:@"txtPassword"] length] )) {
//		strError = @"Please Enter Password";
		Flag = 1;
/*        
	}else if (![[self.dictParentsData objectForKey:@"txtBirthDate"] length] > 0) {
//		strError = MSG_ERROR_VALID_BIRTHDATE1;
		Flag = 1;
	}else if (![[self.dictParentsData objectForKey:@"txtZIP"] length] > 0) {
//		strError = MSG_ERROR_VALID_ZIP;
		Flag = 1;
	}else if ([[self.dictParentsData objectForKey:@"txtZIP"] length] != 5) {
//		strError = MSG_ERROR_VALID_ZIP;
		Flag = 1;
*/ 
	}
	
	
	if (!Flag) {
		if (!isValidEmailAddress([self.dictParentsData objectForKey:@"txtEmail"])) {
			Flag = 1;
//			strError = MSG_ERROR_VALID_EMAIL1;
		}
	}
	
	if ([[self.dictParentsData objectForKey:@"txtSpouseEmail"] length] > 0) {
		if (!isValidEmailAddress([self.dictParentsData objectForKey:@"txtSpouseEmail"])) {
			Flag = 1;
//			strError = MSG_ERROR_VALID_EMAIL1;
		}
	}
	
	//	 if (Flag) {
	//	 UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Error!" 
	//	 message:[NSString stringWithFormat:@"%@",strError] 
	//	 delegate:self 
	//	 cancelButtonTitle:nil otherButtonTitles:@"Try Again",nil];
	//	 [objAlert show];
	//	 [objAlert release];
	//	 }
	if (Flag) {
		return NO;
	}
	return YES;
	
}
- (void) registerParents : (id) sender {
	[self.view endEditing:YES];
	
	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke userRegistration:[self.dictParentsData objectForKey:@"txtFirstName"] 
					  lastName:[self.dictParentsData objectForKey:@"txtLastName"] 
						 email:[self.dictParentsData objectForKey:@"txtEmail"] 
						  pass:[self.dictParentsData objectForKey:@"txtPassword"] 
						   DOB:[self.dictParentsData objectForKey:@"txtBirthDate"] 
				   spouseEmail:[self.dictParentsData objectForKey:@"txtSpouseEmail"] 
						dadMom:[self.dictParentsData objectForKey:@"txtParentType"] 
						 photo:[self.dictParentsData objectForKey:@"userPhotoPath"] 
						   ZIP:[self.dictParentsData objectForKey:@"txtZIP"] 
	 ];
	
	/*
	 UIImage *currentImage = [self captureScreen];
	 [self pushingViewController:currentImage];
	 
	 UserRegStepTwo *userRegStepTwo = [[UserRegStepTwo alloc] initWithNibName:@"UserRegStepTwo" bundle:nil];
	 userRegStepTwo.prevContImage = currentImage;
	 userRegStepTwo.ParentsData = self.dictParentsData;
	 [self.navigationController pushViewController:userRegStepTwo animated:NO];
	 [userRegStepTwo release];
	 */
}

- (void) nextPageClicked : (id)sender {
	
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	
	UserRegStepTwo *userRegStepTwo = [[UserRegStepTwo alloc] initWithNibName:@"UserRegStepTwo" bundle:nil];
	userRegStepTwo.prevContImage = currentImage;
	userRegStepTwo.ParentsData = self.dictParentsData;
	[self.navigationController pushViewController:userRegStepTwo animated:NO];
	[userRegStepTwo release];
}

- (void) cancelSignUpClicked : (id) sender {
	
	[self popViewController];
}

#pragma mark -
#pragma mark TableView Delegate Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (section==0) {
		return 2;
	}
	if (section==1) {
		return 2;
	}
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 44;
	}
	return 44;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 63;
	}
	
	return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 65)] autorelease];
	if(section == 0){
		
		UILabel *headerName = [[UILabel alloc] initWithFrame:CGRectMake(92, 17, 150, 20)];
		headerName.textAlignment = UITextAlignmentLeft;
		headerName.textColor = grayLabelColor;
		headerName.layer.shadowColor = [UIColor whiteColor].CGColor;
		[headerName.layer setShadowOffset:CGSizeMake(0, 10)];
		headerName.layer.shadowRadius = 8.0;
		headerName.text = @"2 simple steps";
		[headerName setFont:[UIFont fontWithName:@"helvetica Neue Thin" size:15]];
		headerName.backgroundColor = [UIColor clearColor];
		[vi addSubview:headerName];
		[headerName release];
		
		UIImageView *step = [[UIImageView alloc] initWithFrame:CGRectMake(210, 12, 113, 33)];
		[step setBackgroundColor:[UIColor clearColor]];
		[step setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"img_step1")]];
		[vi addSubview:step];
		[step release];
		
		vi.clipsToBounds = NO;
	}
	return vi;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	int sectionInd = [indexPath section];
	int rowIndex = [indexPath row];
	
	if (sectionInd == 0){
		NSString *CellIdentifier = @"UserInfoCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.indentationLevel = 1;
			cell.indentationWidth = 74;
			cell.textLabel.font = [UIFont boldSystemFontOfSize:18.0];	
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			UITextField *txt_cell = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 20)];
			txt_cell.tag = 1;
			[txt_cell addTarget:self action:@selector(editingStart:) forControlEvents:UIControlEventEditingDidBegin];
			[txt_cell addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[txt_cell addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			[txt_cell setClearButtonMode:UITextFieldViewModeAlways];
			txt_cell.autocorrectionType = UITextAutocorrectionTypeNo;
			txt_cell.autocapitalizationType = UITextAutocapitalizationTypeWords;
			txt_cell.font = [UIFont systemFontOfSize:16];
			txt_cell.textColor = [UIColor darkGrayColor];
			txt_cell.returnKeyType = UIReturnKeyNext;
			txt_cell.backgroundColor = [UIColor clearColor];
			[txt_cell setKeyboardType:UIKeyboardTypeAlphabet];
			[cell.contentView addSubview:txt_cell];
			[txt_cell release];
			
			UILabel *lblDate = [[UILabel alloc] initWithFrame:CGRectMake(105, 10, 150, 20)];
			lblDate.textAlignment = UITextAlignmentLeft;
			lblDate.tag = 2;
			lblDate.backgroundColor = [UIColor clearColor];
			lblDate.font = [UIFont systemFontOfSize:14];
			[cell.contentView addSubview:lblDate];
			[lblDate release];
			
			UIButton *btnSelectDOB = [UIButton buttonWithType:UIButtonTypeCustom];
			btnSelectDOB.userInteractionEnabled = NO;
			btnSelectDOB.tag = 3;
			btnSelectDOB.backgroundColor = [UIColor clearColor];
			btnSelectDOB.frame = CGRectMake(10, 7, 280, 30);
			[btnSelectDOB addTarget:self action:@selector(selBirthDate:) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:btnSelectDOB];
			
		}
		
		UITextField *txt_cell = (UITextField *)[cell.contentView viewWithTag:1];
		//	UILabel *lblDate = (UILabel *)[cell.contentView viewWithTag:2];
		UIButton *btnSelectDOB = (UIButton *)[cell.contentView viewWithTag:3];
		
		txt_cell.userInteractionEnabled = YES;
		btnSelectDOB.userInteractionEnabled = NO;
		
		switch (indexPath.row) {
			case 0:
				btnSelectDOB.userInteractionEnabled = NO;
				txt_cell.placeholder = @"First Name";
				break;
			case 1:
				btnSelectDOB.userInteractionEnabled = NO;
				txt_cell.placeholder = @"Last Name";
				break;
			case 2:
				txt_cell.userInteractionEnabled = NO;
				btnSelectDOB.userInteractionEnabled = YES;
				txt_cell.placeholder = @"Birthday";
				NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
				[formatter setDateFormat:@"yyy-MM-dd"];
				NSDate *dt = [formatter dateFromString:DefaultStringValue([self.dictParentsData objectForKey:@"txtBirthDate"])];
				if (dt) {
					[formatter setDateFormat:@"d MMM yyyy"];
					[txt_cell setText:[formatter stringFromDate:dt]];
				}else {
					[txt_cell setText:@""];
				}
				[formatter release];
				
				break;
			case 3:
				btnSelectDOB.userInteractionEnabled = NO;
				txt_cell.placeholder = @"Zip Code";
				[txt_cell addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
				[txt_cell setKeyboardType:UIKeyboardTypeNumberPad];
				break;
				
			default:
				break;
		}
		
		cell.tag = indexPath.row;
		return cell;
	}else if (sectionInd == 1) {
		NSString *emailCell = @"emailCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:emailCell];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:emailCell] autorelease];
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			UITextField *txt_cell = [[UITextField alloc] initWithFrame:CGRectMake(15, 10, 280, 20)];
			txt_cell.tag = 11;
			[txt_cell addTarget:self action:@selector(editingStart:) forControlEvents:UIControlEventEditingDidBegin];
			[txt_cell addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[txt_cell addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			[txt_cell setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			txt_cell.autocorrectionType = UITextAutocorrectionTypeNo;
			[txt_cell setClearButtonMode:UITextFieldViewModeAlways];
			//	txt_cell.delegate = self;
			txt_cell.textColor = [UIColor darkGrayColor];
			txt_cell.font = [UIFont systemFontOfSize:16];
			txt_cell.returnKeyType = UIReturnKeyNext;
			txt_cell.backgroundColor = [UIColor clearColor];
			[txt_cell setKeyboardType:UIKeyboardTypeEmailAddress];
			[cell.contentView addSubview:txt_cell];
			[txt_cell release];
			
		}
		
		UITextField *txt_cell = (UITextField *)[cell viewWithTag:11];
		switch (rowIndex) {
			case 0:
				txt_cell.placeholder = @"Email";
				break;
			case 1:
				txt_cell.secureTextEntry = YES;
				txt_cell.placeholder = @"Password";
				break;
			default:
				break;
		}
		cell.tag = indexPath.row;
		return cell;
	}
	else if (sectionInd == 2) {
		NSString *Identifier = @"spouseEmailCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
		
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier] autorelease];
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			UITextField *txt_cell = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
			txt_cell.tag = 21;
			[txt_cell addTarget:self action:@selector(editingStart:) forControlEvents:UIControlEventEditingDidBegin];
			[txt_cell addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[txt_cell addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			[txt_cell setClearButtonMode:UITextFieldViewModeAlways];
			txt_cell.font = [UIFont systemFontOfSize:14];
			txt_cell.autocorrectionType = UITextAutocorrectionTypeNo;
			txt_cell.returnKeyType = UIReturnKeyNext;
			txt_cell.backgroundColor = [UIColor clearColor];
			[txt_cell setKeyboardType:UIKeyboardTypeAlphabet];
			[cell.contentView addSubview:txt_cell];
			[txt_cell release];
			
			UIButton *btn_info = [UIButton buttonWithType:UIButtonTypeInfoLight];
			[btn_info setFrame:CGRectMake(270, 7, 25, 23)];
			[btn_info addTarget:self action:@selector(spouseInfoClicked:) forControlEvents:UIControlEventTouchUpInside];
			[btn_info setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"spouse_info.png")] forState:UIControlStateNormal];
			[cell.contentView addSubview:btn_info];
			
		}
		
		UITextField *txt_cell = (UITextField *)[cell viewWithTag:21];
		txt_cell.placeholder = @"Spouse Email (Optional)";
		txt_cell.font  = [UIFont italicSystemFontOfSize:14];
		
		return cell;
	}
	else if (sectionInd == 3) {
		NSString *birthDayCell = @"birthDayCell";
		CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:birthDayCell];
		if (cell == nil) {
			cell = [[[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:birthDayCell] autorelease];
			cell.content.cellStyle = CustomTableViewCellStyleVerticalLine;
			cell.content.startPoint = CGPointMake(102, 0);
			
			UILabel *lblProfileField = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 90, 30)];
			lblProfileField.tag = 1001;
			lblProfileField.text = @"Birthday";
			lblProfileField.textAlignment = UITextAlignmentRight;
			lblProfileField.backgroundColor = [UIColor clearColor];
			lblProfileField.font = [UIFont boldSystemFontOfSize:13];
			[cell.contentView addSubview:lblProfileField];
			[lblProfileField release];
			
			UILabel *lblDate = [[UILabel alloc] initWithFrame:CGRectMake(105, 7, 150, 30)];
			lblDate.textAlignment = UITextAlignmentLeft;
			lblDate.tag = 1002;
			lblDate.backgroundColor = [UIColor clearColor];
			lblDate.font = [UIFont systemFontOfSize:12];
			[cell.contentView addSubview:lblDate];
			[lblDate release];
			
			UIButton *btnSelectDOB = [UIButton buttonWithType:UIButtonTypeCustom];
			btnSelectDOB.tag = 1003;
			btnSelectDOB.backgroundColor = [UIColor clearColor];
			btnSelectDOB.frame = CGRectMake(105, 7, 150, 30);
			[btnSelectDOB addTarget:self action:@selector(selBirthDate:) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:btnSelectDOB];
		}
		
		UIButton *btn_dob = (UIButton*)[cell viewWithTag:1003];
		btn_dob.enabled = !isUserRegistered;
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyy-MM-dd"];
		NSDate *dt = [formatter dateFromString:DefaultStringValue([self.dictParentsData objectForKey:@"txtBirthDate"])];
		if (dt) {
			[formatter setDateFormat:@"d MMM yyyy"];
			[(UILabel*)[cell viewWithTag:1002] setText:[formatter stringFromDate:dt]];
		}else {
			[(UILabel*)[cell viewWithTag:1002] setText:@""];
		}
		[formatter release];
		
		return cell;
	}
	else if(sectionInd == 5) {
		NSString *segmentCell = @"segmentCell";
		CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:segmentCell];
		if (cell == nil) {
			cell = [[[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:segmentCell] autorelease];
			cell.content.cellStyle = CustomTableViewCellStyleVerticalLine;
			cell.content.startPoint = CGPointMake(102, 0);
			
			UILabel *lblProfileField = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 90, 30)];
			lblProfileField.tag = 1001;
			lblProfileField.text = @"I am a";
			lblProfileField.textAlignment = UITextAlignmentRight;
			lblProfileField.backgroundColor = [UIColor clearColor];
			lblProfileField.font = [UIFont boldSystemFontOfSize:13];
			[cell.contentView addSubview:lblProfileField];
			[lblProfileField release];
			
			UISegmentedControl *seg_con = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Dad", @"Mom", nil]];
			seg_con.tag = 1002;
			[seg_con setSelectedSegmentIndex:-1];
			[seg_con addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
			seg_con.frame = CGRectMake(120, 10, 180, 24);
			seg_con.segmentedControlStyle = UISegmentedControlStyleBar;
			[cell addSubview:seg_con];
			[seg_con release];
		}
		
		//		UISegmentedControl *seg_cont = (UISegmentedControl*)[cell viewWithTag:1002];
		//		seg_cont.enabled = !isUserRegistered;
		//		
		//		if ([[self.dictParentsData objectForKey:@"txtParentType"] isEqualToString:@"Dad"]) {
		//			seg_cont.selectedSegmentIndex = 0;
		//		}else {
		//			seg_cont.selectedSegmentIndex = 1;
		//		}
		
		return cell;
	}
	else {
		NSString *normalCell = @"normalCell";
		CustomTableViewCell *cell = (CustomTableViewCell*)[tableView dequeueReusableCellWithIdentifier:normalCell];
		if (cell == nil) {
			cell = [[[CustomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:normalCell] autorelease];
			cell.content.cellStyle = CustomTableViewCellStyleVerticalLine;
			cell.content.startPoint = CGPointMake(102, 0);
			
			UILabel *lblProfileField = [[UILabel alloc] initWithFrame:CGRectMake(0, 7, 90, 30)];
			lblProfileField.tag = 1001;
			lblProfileField.textAlignment = UITextAlignmentRight;
			lblProfileField.backgroundColor = [UIColor clearColor];
			lblProfileField.font = [UIFont boldSystemFontOfSize:13];
			[cell.contentView addSubview:lblProfileField];
			[lblProfileField release];
			
			UITextField *txtProfileField= [[UITextField alloc] initWithFrame:CGRectMake(105, 7, 150, 30)];
			txtProfileField.backgroundColor = [UIColor clearColor];
			txtProfileField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			[txtProfileField addTarget:self action:@selector(editingStart:) forControlEvents:UIControlEventEditingDidBegin];
			[txtProfileField addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[txtProfileField addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			[txtProfileField setClearButtonMode:UITextFieldViewModeAlways];
			txtProfileField.tag = 1002;
			txtProfileField.autocorrectionType = UITextAutocorrectionTypeNo;
			[txtProfileField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			txtProfileField.returnKeyType = UIReturnKeyDone;
			txtProfileField.font = [UIFont systemFontOfSize:12];
			[cell.contentView addSubview:txtProfileField];
			[txtProfileField release];
		}
		
		UILabel *lbl_field = (UILabel*)[cell viewWithTag:1001];
		UITextField *txt_field = (UITextField*)[cell viewWithTag:1002];
		
		txt_field.enabled = !isUserRegistered;
		
		txt_field.placeholder = @"";
		txt_field.secureTextEntry = NO;
		switch (sectionInd) {
			case 1:{
				lbl_field.text = @"Email";
				txt_field.text = DefaultStringValue([self.dictParentsData objectForKey:@"txtEmail"]);
				txt_field.keyboardType = UIKeyboardTypeEmailAddress;
				break;
			}
			case 2:{
				txt_field.secureTextEntry = YES;
				if (rowIndex==0) {
					lbl_field.text = @"Password";
					txt_field.text = DefaultStringValue([self.dictParentsData objectForKey:@"txtPassword"]);
				}
				else if(rowIndex==1) {
					lbl_field.text = @"Confirm";
					txt_field.text = DefaultStringValue([self.dictParentsData objectForKey:@"txtConfirmPassword"]);
				}
				break;
			}
			case 4:{
				lbl_field.text = @"Zip Code";
				txt_field.text = DefaultStringValue([self.dictParentsData objectForKey:@"txtZIP"]);
				[txt_field addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
				txt_field.keyboardType = UIKeyboardTypeNumberPad;
				[txt_field setClearsOnBeginEditing:YES];
				break;
			}
			case 6:{
				lbl_field.text = @"Spouse Email";
				txt_field.placeholder = @"( Optional )";
				txt_field.text = DefaultStringValue([self.dictParentsData objectForKey:@"txtSpouseEmail"]);
				txt_field.keyboardType = UIKeyboardTypeEmailAddress;
				break;
			}	
			default:
				break;
		}
		
		if (rowIndex == 1) {
			txt_field.returnKeyType = UIReturnKeyNext;
		}else if(rowIndex == 6) {
			txt_field.returnKeyType = UIReturnKeyDone;
		}else {
			txt_field.returnKeyType = UIReturnKeyNext;
		}
		
		cell.tag = sectionInd;
		return cell;
	}
	
	return nil;
}

/*
 - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
 // replace backgroundView if it's not our own
 if (indexPath.section == 0)	{
 if ([cell.backgroundView class] != [UIView class]) {
 
 UIGraphicsBeginImageContext(cell.backgroundView.bounds.size);
 [cell.backgroundView.layer renderInContext:UIGraphicsGetCurrentContext()];
 UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 UIImage *shrunkenBackgroundImage = [backgroundImage stretchableImageWithHorizontalCapWith:20.0 verticalCapWith:round((backgroundImage.size.height - 1.0)/2.0)];
 
 UIView *replacementBackgroundView = [[UIView alloc] initWithFrame:cell.backgroundView.frame];
 replacementBackgroundView.autoresizesSubviews;
 
 UIImageView *indentedView = [[UIImageView alloc] initWithFrame:CGRectMake(PHOTO_INDENT, 0, replacementBackgroundView.bounds.size.width - PHOTO_INDENT,  replacementBackgroundView.bounds.size.height)];
 indentedView.image = shrunkenBackgroundImage;
 indentedView.contentMode = UIViewContentModeRedraw;
 indentedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
 indentedView.contentStretch = CGRectMake(0.2, 0, 0.5, 1);
 [replacementBackgroundView addSubview:indentedView];
 [indentedView release];
 
 cell.backgroundView = replacementBackgroundView;
 }
 
 if ([cell.selectedBackgroundView class] != [UIView class]) {
 
 UIGraphicsBeginImageContext(cell.selectedBackgroundView.bounds.size);
 [cell.selectedBackgroundView.layer renderInContext:UIGraphicsGetCurrentContext()];
 UIImage *backgroundImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 UIImage *shrunkenBackgroundImage = [backgroundImage stretchableImageWithHorizontalCapWith:20.0 verticalCapWith:round((backgroundImage.size.height - 1.0)/2.0)];
 
 UIView *replacementBackgroundView = [[UIView alloc] initWithFrame:cell.backgroundView.frame];
 replacementBackgroundView.autoresizesSubviews;
 
 
 UIImageView *indentedView = [[UIImageView alloc] initWithFrame:CGRectMake(PHOTO_INDENT, 0, replacementBackgroundView.bounds.size.width - PHOTO_INDENT,  replacementBackgroundView.bounds.size.height)];
 indentedView.image = shrunkenBackgroundImage;
 indentedView.contentMode = UIViewContentModeRedraw;
 indentedView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
 indentedView.contentStretch = CGRectMake(0.2, 0, 0.5, 1);
 [replacementBackgroundView addSubview:indentedView];
 [indentedView release];
 
 cell.selectedBackgroundView = replacementBackgroundView;
 }
 
 /*
 // naughty: we could add the photo directy to the tableView's content here
 CGRect frame = cell.frame;
 photoImageView.frame = CGRectMake(9.0, frame.origin.y, 64.0, 64.0);
 [tableView addSubview:photoImageView];
 
 // head sticker
 UIImageView *heartView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"heart.png"]];
 heartView.frame = CGRectMake(photoImageView.frame.origin.x + 40.0, photoImageView.frame.origin.y + 45.0, heartView.frame.size.width, heartView.frame.size.height);
 [tableView addSubview:heartView];
 [heartView release];
 
 }
 }
 */
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) spouseInfoClicked : (id) sender {
	
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	
	UserRegSpouseInfo *userRegSpouseInfo = [[UserRegSpouseInfo alloc]initWithNibName:@"UserRegSpouseInfo" bundle:nil];
	userRegSpouseInfo.prevContImage = currentImage;
	[self.navigationController pushViewController:userRegSpouseInfo animated:NO];
	[userRegSpouseInfo release];
	
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSCharacterSet *cs;
	NSString *filtered;
	NSString *fname = textField.text;
	// Check for period
	if (range.length == 1) {
		return YES;
	}
	if ([fname rangeOfString:@"."].location == NSNotFound)
	{
		cs = [[NSCharacterSet characterSetWithCharactersInString:NUMBERSPERIOD] invertedSet];
		filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
		if ([filtered isEqualToString:@""]) {
			//			if ([string isEqualToString:@"\n"]) {
			[textField resignFirstResponder];
			return NO;
			//			}
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!"
														   message:@"Special Characters not allowed"
														  delegate:self 
												 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
			
		}
		return [string isEqualToString:filtered];
	}
	return NO;
}	

#pragma mark -
#pragma mark TableView Cell Methods

- (void) segmentChanged : (id) sender {
	
	UISegmentedControl *seg_cont = (UISegmentedControl*)sender;
	int index = seg_cont.selectedSegmentIndex;
	if (index == 0) {
		[self.dictParentsData setObject:@"Dad" forKey:@"txtParentType"];
	}else {
		[self.dictParentsData setObject:@"Mom" forKey:@"txtParentType"];
	}
}

- (void) cancelDate : (id) sender {
	
	UIView *dateView = [[DELEGATE window] viewWithTag:121121];
	if (dateView) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:Trans_Duration];
		[dateView setFrame:CGRectMake( 0, 416, 320, 416)];
		[UIView commitAnimations];
		[dateView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:Trans_Duration];
	}
}

- (void) saveDate:(UIButton *)btnDone {
	
	//	[self timeIntervalFor];
	UIView *DateView = [[DELEGATE window] viewWithTag:121121];
	UIDatePicker *DatePick = (UIDatePicker*)[DateView viewWithTag:111];
	NSDate *selectedDate = DatePick.date;
	NSTimeInterval interval = [selectedDate timeIntervalSinceNow];
	
	NSString *ErrorMessage = nil;
	if (interval > 0) {
		ErrorMessage = MSG_ERROR_VALID_BIRTHDATE2;
	}else if (interval > -568080000) {		//timeInterval For 18 years
		ErrorMessage = MSG_ERROR_VALID_BIRTHDATE3;
	}
	
	if (ErrorMessage) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrorMessage 
													   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else {
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		[self.dictParentsData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtBirthDate"];
		[formatter release];
		[self cancelDate:nil];
		if ([self isFormValid]) {
			self.navigationItem.rightBarButtonItem.enabled = YES;
		}else {
			self.navigationItem.rightBarButtonItem.enabled = NO;
		}	
		[self.regStepOneTV reloadData];
	}
}

- (void) selBirthDate: (id) sender {
	
	[self.view endEditing:YES];
	
	UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 265, 320, 300)];
	pickerView.datePickerMode = UIDatePickerModeDate;
	pickerView.tag = 111;
	
	
	if ([self.dictParentsData objectForKey:@"txtBirthDate"]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		pickerView.date = [formatter dateFromString:[self.dictParentsData objectForKey:@"txtBirthDate"]];
		[formatter release];
	}
	
	
	UIView *objView = [[UIView alloc] initWithFrame:CGRectMake(0, 480, 320, 480)];
	objView.tag = 121121;
	objView.backgroundColor = [UIColor clearColor];
	[objView addSubview:pickerView];
	[pickerView release];
	
	UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 221, 320, 44)];
//	bar.tintColor = [UIColor blackColor];
	bar.tag = 111;
	bar.alpha = 1.0;
	
	UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@""];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
															 style:UIBarButtonItemStyleDone 
															target:self 
															action:@selector(saveDate:)];
	item.rightBarButtonItem = done;
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
															   style:UIBarButtonItemStyleDone 
															  target:self 
															  action:@selector(cancelDate:)];
	item.leftBarButtonItem = cancel;
	
	bar.items = [NSArray arrayWithObject:item];
	[objView addSubview:bar];
	[bar release];
	[item release];
	
	[[DELEGATE window] addSubview:objView];
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.5];
	[objView setFrame:CGRectMake( 0, 0, 320, 480)];
	[UIView commitAnimations];
	[objView release];
	
}

- (void) editingChanged : (id) sender {
	UITextField *textField = (UITextField*)sender;
	NSString *text = textField.text;		
	if ([text length]>=5) {
		[textField resignFirstResponder];
	}
	
}
- (void) editingStart : (id) sender {
	
	UITextField *textField = (UITextField*)sender;
	CGRect textFieldRect = [self.regStepOneTV convertRect:textField.bounds fromView:textField];
	CGRect viewRect = [self.regStepOneTV convertRect:self.regStepOneTV.bounds fromView:self.regStepOneTV];
	CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
	CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
	CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
	CGFloat heightFraction = numerator / denominator;
	
	if (heightFraction < 0.0) {
		heightFraction = 0.0;
	}else if (heightFraction > 1.0) {
		heightFraction = 1.0;
	}
	
	animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
	
	if ([self.regStepOneTV indexPathForCell:(UITableViewCell *)[[textField superview]superview]].section==6) 
		animatedDistance = 230.0;
	
	
	CGRect viewFrame = self.regStepOneTV.frame;
	viewFrame.origin.y -= animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
	[self.regStepOneTV setFrame:viewFrame];
	[UIView commitAnimations];
}

- (void) nextPressed : (id) sender {
	
	UITextField *txt_field = (UITextField*)sender;
	[txt_field resignFirstResponder];
	
	id objCell = [[txt_field superview] superview];
	UITableViewCell *nextCell = nil;
	if (objCell && [objCell isKindOfClass:[UITableViewCell class]]) {
		UITableViewCell *tableCell = (UITableViewCell*)objCell;
		NSString *reuseIdentifier = tableCell.reuseIdentifier;
		if ([reuseIdentifier isEqualToString:@"UserInfoCell"]) {
			int currTag = tableCell.tag;
			if (currTag == 0) {
				nextCell = [self.regStepOneTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
				if (nextCell) {
					[[nextCell.contentView viewWithTag:1] becomeFirstResponder];
				}
			}else if (currTag == 1) {
				nextCell = [self.regStepOneTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
				if (nextCell) {
					[[nextCell.contentView viewWithTag:1] becomeFirstResponder];
				}
			}else if (currTag == 2) {
				nextCell = [self.regStepOneTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
				if (nextCell) {
					[[nextCell.contentView viewWithTag:1] becomeFirstResponder];
				}
			}
		}else if([reuseIdentifier isEqualToString:@"emailCell"]){
			int currTag = tableCell.tag;
			if (currTag == 0) {
				nextCell = [self.regStepOneTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
				if (nextCell) {
					[[nextCell.contentView viewWithTag:11] becomeFirstResponder];
				}
			}
		}
	}
	
}

- (void) editingEnded : (id) sender {
	UITextField *txt_field = (UITextField*)sender;
	NSString *value = txt_field.text;
	id objCell = [[txt_field superview] superview];
	if (objCell && [objCell isKindOfClass:[UITableViewCell class]]) {
		UITableViewCell *tableCell = (UITableViewCell*)objCell;
		NSString *reuseIdentifier = tableCell.reuseIdentifier;
		if ([reuseIdentifier isEqualToString:@"UserInfoCell"]) {
			int currTag = tableCell.tag;
			if (currTag == 0) {
				[self.dictParentsData setObject:DefaultStringValue(value) forKey:@"txtFirstName"];
			}else if (currTag == 1){
				[self.dictParentsData setObject:DefaultStringValue(value) forKey:@"txtLastName"];
			}else if (currTag == 3){
				[self.dictParentsData setObject:DefaultStringValue(value) forKey:@"txtZIP"];
			}
		}else if([reuseIdentifier isEqualToString:@"emailCell"]){
			int currTag = tableCell.tag;
			if (currTag == 0) {
				[self.dictParentsData setObject:DefaultStringValue(value) forKey:@"txtEmail"];
			}else if (currTag == 1) {
				[self.dictParentsData setObject:DefaultStringValue(value) forKey:@"txtPassword"];
			}
		}else if ([reuseIdentifier isEqualToString:@"spouseEmailCell"]) {
			[self.dictParentsData setObject:DefaultStringValue(value) forKey:@"txtSpouseEmail"];
		}
	}
	CGRect viewFrame = [self.regStepOneTV frame];
	viewFrame.origin.y += animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[self.regStepOneTV setFrame:viewFrame];
	[UIView commitAnimations];
	
	[sender resignFirstResponder];
	
	if ([self isFormValid]) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}else {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}	
	
}

- (void) verifyPassword : (NSString *) password {
	if (![password isEqualToString:[self.dictParentsData objectForKey:@"txtPassword"]]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error"
													   message:MSG_ERROR_VALID_PASSWORD 
													  delegate:self
											 cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else {
		[self.dictParentsData setObject:DefaultStringValue(password) forKey:@"txtConfirmPassword"];
	}
	
}
- (void) funTermsAndCondition:(id) sender {
	
	TermsAndCondView *termsAndCondView = [[TermsAndCondView alloc] initWithNibName:@"TermsAndCondView" bundle:nil];
	[self.navigationController pushViewController:termsAndCondView animated:YES];
	[termsAndCondView release];
}

- (void) selectImage : (id) sender {
	
	if (!isImageSet) {
		UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Choose Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Photo Library" otherButtonTitles:@"Camera", nil];
		popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[popupQuery showInView:self.view];
		[popupQuery release];
	}else {
		UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"Edit Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Photo Library" otherButtonTitles:@"Camera", @"Delete Photo", nil];
		popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
		[popupQuery showInView:self.view];
		[popupQuery release];
	}
}

#pragma mark -
#pragma mark ActionSheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 0) {
		UIImagePickerController *pc = [[UIImagePickerController alloc] init];
		pc.delegate = self;
		pc.allowsEditing = YES;
		pc.mediaTypes = [NSArray arrayWithObjects:(id)kUTTypeImage, nil];
		pc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		[DELEGATE putSideViewToBack];
		[self presentModalViewController:pc animated:NO];
		[pc release];
	}else if(buttonIndex == 1) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			UIImagePickerController *pc = [[UIImagePickerController alloc] init];
			pc.delegate = self;
			pc.allowsEditing = YES;
			pc.mediaTypes = [NSArray arrayWithObjects:(id)kUTTypeImage, nil];
			pc.sourceType = UIImagePickerControllerSourceTypeCamera;
			[DELEGATE putSideViewToBack];
			[self presentModalViewController:pc animated:NO];
			[pc release];
		}else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
															message:MSG_ERROR_NO_CAMERA
														   delegate:self 
												  cancelButtonTitle:@"Ok" 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}else {
		if (isImageSet) {
			if (buttonIndex == 2) {
				//TODO: Remove the previous attachment.
			}
		}
	}
}

#pragma mark -
#pragma mark ImagePickerController

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
	[DELEGATE bringSideViewToFront];
	[self dismissModalViewControllerAnimated:YES];
}

-  (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)img editingInfo:(NSDictionary *)editInfo {
	
	[DELEGATE putSideViewToBack];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSString *strImageName = [NSString stringWithFormat:@"%@.jpg", [formatter stringFromDate:[NSDate date]]];
	[formatter release];
	
	isImageSet = TRUE;
	NSData *img_data = UIImageJPEGRepresentation(img, 0.7);
	[img_data writeToFile:[DOC_DIR stringByAppendingPathComponent:strImageName] atomically:NO];
	[self.dictParentsData setObject:[DOC_DIR stringByAppendingPathComponent:strImageName] forKey:@"userPhotoPath"];
	//	[photoImageView setImage:img forState:UIControlStateNormal];
	[self.regStepOneTV reloadData];
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Tyke Api Delegate

- (void) logInResponce : (NSData*) data {
	
	BOOL success  = NO;
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([response objectForKey:@"responseStatus"]) {
		if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
			
			[[DELEGATE dict_userInfo] setObject:[self.dictParentsData objectForKey:@"txtEmail"] forKey:@"user_name"];
			[[DELEGATE dict_userInfo] setObject:[self.dictParentsData objectForKey:@"txtPassword"] forKey:@"password"];
			[[DELEGATE dict_userInfo] setObject:[response objectForKey:@"response"] forKey:@"response"];
			
			[self.dictParentsData setObject:[[response objectForKey:@"response"] objectForKey:@"AccountConfirmationFlag"] forKey:@"AccountConfirmationFlag"];
			[self.dictParentsData setObject:[[response objectForKey:@"response"] objectForKey:@"AccountDaysEff"] forKey:@"AccountDaysEff"];	
		
			[[DELEGATE dict_userInfo] setObject:[[response objectForKey:@"response"] objectForKey:@"sessionID"] forKey:@"sessionID"];
			
			[[DELEGATE dict_userInfo] writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userInfo.plist"] atomically:NO];
			success = YES;
		}
	}
	
	if (!success) {
		UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
														   message:MSG_ERROR_VALID_REGISTER3
														  delegate:nil 
												 cancelButtonTitle:@"Ok" 
												 otherButtonTitles:nil];
		[objAlert show];
		[objAlert release];
	}else {
		if ([[[response objectForKey:@"response"] objectForKey:@"ProfileCompletionStatus"] isEqualToNumber:[NSNumber numberWithInt:0]]) {
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			
			UserRegStepTwo *userRegStepTwo = [[UserRegStepTwo alloc] initWithNibName:@"UserRegStepTwo" bundle:nil];
			userRegStepTwo.prevContImage = currentImage;
			userRegStepTwo.ParentsData = self.dictParentsData;
			[self.navigationController pushViewController:userRegStepTwo animated:NO];
			[userRegStepTwo release];
			
			isUserRegistered = YES;
		}else {
			[DELEGATE userLoggedInWithDict:[DELEGATE dict_userInfo]];
		}


	}
	
	[DELEGATE removeLoadingView:self.vi_main];
}

- (void) userRegisterResponse : (NSData*) data {
	
	BOOL success  = NO;
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([response objectForKey:@"responseStatus"]) {
		if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
			success = YES;
		}
	}
	
	if (!success) {
		
		UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
														   message:[[response objectForKey:@"response"] objectForKey:@"reasonStr"]//MSG_ERROR_VALID_REGISTER2 
														  delegate:nil 
												 cancelButtonTitle:@"Ok" 
												 otherButtonTitles:nil];
		[objAlert show];
		[objAlert release];
		
		[DELEGATE removeLoadingView:self.vi_main];
	}else {
//		NSLog(@"username: %@",[self.dictParentsData objectForKey:@"txtEmail"]);
//        NSLog(@"password: %@", [self.dictParentsData objectForKey:@"txtPassword"]);
//        NSLog(@"devicetoken: %@", [DELEGATE apnDeviceID]);
        
		[api_tyke userLogin:[self.dictParentsData objectForKey:@"txtEmail"] txtPassword:[self.dictParentsData objectForKey:@"txtPassword"] txtDToken:[DELEGATE apnDeviceID]];
	}
	
}

- (void) MarkUserPosResponse : (NSData *) data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		
		UserRegStepTwo *userRegStepTwo = [[UserRegStepTwo alloc] initWithNibName:@"UserRegStepTwo" bundle:nil];
		userRegStepTwo.prevContImage = currentImage;
		userRegStepTwo.ParentsData = self.dictParentsData;
		[self.navigationController pushViewController:userRegStepTwo animated:NO];
		[userRegStepTwo release];
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

#pragma mark -

- (void)dealloc {
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
	[self.regStepOneTV release];
    [super dealloc];
}

@end
