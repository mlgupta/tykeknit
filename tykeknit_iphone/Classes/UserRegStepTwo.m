//
//  UserRegStepTwo.m
//  TykeKnit
//
//  Created by Abhinit Tiwari on 06/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserRegStepTwo.h"
#import "UserRegStepOne.h"
#import "userAuthentication.h"
#import <QuartzCore/QuartzCore.h>
#import "TykeKnitApi.h"
#import "CustomTableViewCell.h"
#import "CustomSegmentView.h"
#import "VXTTableCellBackground.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PlayDateViewController.h"
#import "FriendsMainViewController.h"
#import "UIImage+Helpers.h"
#import "JSON.h"
#import "LoginViewController.h"
#import "Messages.h"

@implementation UserRegStepTwo
@synthesize regStepTwoTV, ParentsData, dictTykeData,dict_Settings,rightSideView,btn_addMoreTyke;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 160;

- (BOOL) isFormValid : (NSDictionary *) dictForm{
			int Flag = 0;
		if ([[dictForm objectForKey:@"status"] isEqualToString:@"watingToUpload"]) {
//			NSString *strError;

			if (!([[dictForm objectForKey:@"txtTykeFirstName"] length] > 0)) {
//				strError = MSG_ERROR_VALID_NAME1;
				Flag = 1;
			}else if(!([[dictForm objectForKey:@"txtTykeLastName"] length] > 0)) {
//				strError = MSG_ERROR_VALID_NAME2;
				Flag = 1;
			}else if (![[dictForm objectForKey:@"txtBirthDate"] length] > 0) {
//				strError = MSG_ERROR_VALID_BIRTHDATE1;
				Flag = 1;
			}else if (![[dictForm objectForKey:@"gender"] length] > 0) {
//				strError = MSG_ERROR_VALID_GENDER;
				Flag = 1;
			}
			
			if (Flag) {
				
				if ([[dictForm objectForKey:@"txtTykeFirstName"] length] > 0) {
//					strError = [strError stringByAppendingString:[NSString stringWithFormat:@" of %@", [dictForm objectForKey:@"txtTykeFirstName"]]];
				}else {
//					strError = [strError stringByAppendingString:[NSString stringWithFormat:@" of tyke no %d",currentSectionIndex+1]];
				}
			}
		}
	if (Flag) {
		return NO;
	}
	return YES;
}
- (void) cancelSignUpClicked : (id) sender {
	
	[self popViewController];
}

- (void) addCurrentChild : (id) sender {
	
	
	for (int i = 0; i <= [self.dictTykeData count]; i++) {
		NSMutableDictionary *dictCurr = [self.dictTykeData objectForKey:[NSString stringWithFormat:@"%d", i]];	
		if ([dictCurr objectForKey:@"txtTykeFirstName"] && [dictCurr objectForKey:@"txtTykeLastName"] && [dictCurr objectForKey:@"txtBirthDate"] && [dictCurr objectForKey:@"gender"]) {
		}else {
			[self.dictTykeData removeObjectForKey:[NSString stringWithFormat:@"%d", i]];
		}
	}
	
	NSMutableDictionary *dictCurr = [self.dictTykeData objectForKey:[NSString stringWithFormat:@"%d", 0]];
	
	
	[dictCurr setObject:@"uploading" forKey:@"status"];
	if ([dictCurr objectForKey:@"txtTykeFirstName"] && [dictCurr objectForKey:@"txtTykeLastName"] && [dictCurr objectForKey:@"txtBirthDate"] && [dictCurr objectForKey:@"gender"]) {
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke addKid:[dictCurr objectForKey:@"txtTykeFirstName"] 
				lastName:[dictCurr objectForKey:@"txtTykeLastName"] 
					 DOB:[dictCurr objectForKey:@"txtBirthDate"] 
				   photo:[NSString stringWithFormat:@"photo"] 
				  gender:[dictCurr objectForKey:@"gender"]
		 ];
	}else {
		[self.dictTykeData removeObjectForKey:[NSString stringWithFormat:@"%d", 0]];
	}
	
	/* 
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];

	FriendsMainViewController *frdsVC = [[FriendsMainViewController alloc] initWithNibName:@"FriendsMainViewController" bundle:nil ];
	frdsVC.prevContImage = currentImage;
	[self.navigationController pushViewController:frdsVC animated:NO];
	[frdsVC release];
	*/

}

- (void) backClicked : (id) sender {
	[self popViewController];
}

- (void) viewDidLoad {
	
	currentChildAdded = NO;
	animatedDistance = 0.0f;
	api_tyke = [[TykeKnitApi alloc] init];
	api_tyke.delegate = self;
	[self.regStepTwoTV setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
	
//	self.rightSideView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 0, 45, 418)];
//	[self.rightSideView setBackgroundColor:[UIColor clearColor]];
//	[self.rightSideView setImage:[[UIImage imageNamed:@"tab_grad.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:22]];
//	[self.rightSideView setAlpha:0.5];
//	[self.view addSubview:self.rightSideView];
//	[self.rightSideView release];
	
	[self.regStepTwoTV setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	[self.view setBackgroundColor:[UIColor blackColor]];
	
//	[self.regStepTwoTV setBackgroundView:[[[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"registeration_background.png")]]autorelease]];
	[self.regStepTwoTV setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"img_background")]] autorelease]];
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Tyke Info"];
	if (self.ParentsData) {
//		UIButton *btn_default = [DELEGATE getDefaultBarButtonWithTitle:@"Cancel"];
//		[btn_default addTarget:self action:@selector(cancelSignUpClicked:) forControlEvents:UIControlEventTouchUpInside];
//		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_default] autorelease];
	
		UIButton *btn_add = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
		[btn_add addTarget:self action:@selector(addCurrentChild:) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_add] autorelease];
		self.navigationItem.rightBarButtonItem.enabled = NO;
		[self.navigationItem setHidesBackButton:YES];
	}
	//else {
//		UIButton *btn_Back = [DELEGATE getBackBarButton];
//		[btn_Back addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
//		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_Back] autorelease];
//		
//	}
	if ([self.navigationController isEqual:[DELEGATE nav_Settings]]) {
		UIButton *btn_Back = [DELEGATE getBackBarButton];
		[btn_Back addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_Back] autorelease];
		
		UIButton *btn_add = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
		[btn_add addTarget:self action:@selector(addCurrentChild:) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_add] autorelease];
		self.navigationItem.rightBarButtonItem.enabled = NO;
		[self.navigationItem setHidesBackButton:YES];
		
	}
	
	animatedDistance = 0.0f;
	self.regStepTwoTV.allowsSelection = NO;
//	self.regStepTwoTV.backgroundColor = [UIColor clearColor];
	self.regStepTwoTV.sectionFooterHeight = 0.0;
	self.regStepTwoTV.sectionHeaderHeight = 0.0f;
	self.regStepTwoTV.clipsToBounds = NO;
	
		self.dictTykeData = [[NSMutableDictionary alloc] init];
		NSMutableDictionary *dictDummy = [[NSMutableDictionary alloc] init];
		[dictDummy setObject:@"watingToUpload" forKey:@"status"];
		[self.dictTykeData setObject:dictDummy forKey:@"0"];
		[dictDummy release];
	
	numberOfSections = 1;
	currentSectionIndex = 0;
	[super viewDidLoad];
}

- (void) logAllViews : (UIView*)vi{
	
	NSArray *arr = [vi subviews];
	for (UIView *viSub in arr) {
		[self logAllViews:viSub];
	}
}


#pragma mark -
#pragma mark UITableViewDelagate Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

	return numberOfSections;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 4;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0 && [self.navigationController isEqual:[DELEGATE nav_login]]) {
		return 60;
	}
	
	return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 50)] autorelease];
	if(section == 0 && [self.navigationController isEqual:[DELEGATE nav_login]]) {
		
		UILabel *headerName = [[UILabel alloc] initWithFrame:CGRectMake(92, 17, 150, 20)];
		headerName.textAlignment = UITextAlignmentLeft;
		headerName.textColor = [UIColor lightGrayColor];
		headerName.text = @"2 simple steps";
		[headerName setFont:[UIFont fontWithName:@"helvetica Neue Thin" size:15]];
		headerName.backgroundColor = [UIColor clearColor];
		[vi addSubview:headerName];
		[headerName release];
		
		UIImageView *step = [[UIImageView alloc] initWithFrame:CGRectMake(210, 12, 112, 33)];
		[step setBackgroundColor:[UIColor clearColor]];
		[step setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"img_step2")]];
		[vi addSubview:step];
		[step release];

		vi.clipsToBounds = NO;
	}
	return vi;
}
 

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section==numberOfSections-1) {
		return 50;
	}
	else return 1;
	
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	if (section==[tableView numberOfSections]-1) {
		vi.frame = CGRectMake(0, 0, 280, 50);
		UIButton *btnTyke = [UIButton buttonWithType:UIButtonTypeCustom];
		btnTyke.frame = CGRectMake( 20, 15, 150, 26);
		[btnTyke setImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"btnPlus"ofType:@"png"]] forState:UIControlStateNormal];
		btnTyke.titleLabel.font = [UIFont systemFontOfSize:16];
		[btnTyke setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
		[btnTyke addTarget:self action:@selector(funAddMoreTyke:) forControlEvents:UIControlEventTouchUpInside];
		[btnTyke setTitle:@"  Add more tykes" forState:UIControlStateNormal];
		[btnTyke.layer setShadowOffset:CGSizeMake(0, 10)];
		[btnTyke.layer setShadowRadius:5.0];
		[btnTyke.layer setShadowColor:[UIColor whiteColor].CGColor];
		[vi addSubview:btnTyke];
		self.btn_addMoreTyke = btnTyke;
	}
	return vi;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section %3== 0) {
		return 44;
	}
	return 44;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	int section = [indexPath section];

	NSDictionary *dictData = [self.dictTykeData objectForKey:[NSString stringWithFormat:@"%d", section]];
	
		NSString *CellIdentifier = @"InfoCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {

			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];

			UITextField *txt_cell = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, 280, 20)];
			txt_cell.tag = 1;
			[txt_cell addTarget:self action:@selector(editingStart:) forControlEvents:UIControlEventEditingDidBegin];
			[txt_cell addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[txt_cell addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			txt_cell.font = [UIFont systemFontOfSize:16];
			txt_cell.textColor = [UIColor darkGrayColor];
			txt_cell.autocorrectionType = UITextAutocorrectionTypeNo;
			txt_cell.autocorrectionType = UITextAutocapitalizationTypeWords;
			txt_cell.returnKeyType = UIReturnKeyNext;
			txt_cell.backgroundColor = [UIColor clearColor];
			[txt_cell setKeyboardType:UIKeyboardTypeAlphabet];
			[cell.contentView addSubview:txt_cell];
			[txt_cell release];
			
			UIButton *btnSelectDOB = [UIButton buttonWithType:UIButtonTypeCustom];
			btnSelectDOB.userInteractionEnabled = NO;
			btnSelectDOB.tag = 2;
			btnSelectDOB.backgroundColor = [UIColor clearColor];
			btnSelectDOB.frame = CGRectMake(10, 7, 280, 30);
			[btnSelectDOB addTarget:self action:@selector(selBirthDate:) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:btnSelectDOB];
			
			NSMutableArray *arr_segments = [[NSMutableArray alloc]init];
			
			NSMutableDictionary *dict_boy = [[NSMutableDictionary alloc]init];
			[dict_boy setObject:@"index1.png" forKey:@"imageName"];
			[dict_boy setObject:@"Boy" forKey:@"title"];
			[arr_segments addObject:dict_boy];
			[dict_boy release];
			
			NSMutableDictionary *dict_girl = [[NSMutableDictionary alloc]init];
			[dict_girl setObject:@"index2.png" forKey:@"imageName"];
			[dict_girl setObject:@"Girl" forKey:@"title"];
			[arr_segments addObject:dict_girl];
			[dict_girl release];
			
			CustomSegmentView *seg_control = [[CustomSegmentView alloc]initWithFrame:CGRectMake(195, 4, 100, 30) withSegments:[arr_segments autorelease] defaultImage:@"clear" andDelegate:self];
			seg_control.tag = 3;
			[cell.contentView addSubview:seg_control];
			[seg_control release];

			if ([self.navigationController isEqual:[DELEGATE nav_Settings]]) {
				[seg_control setFrame:CGRectMake(145, 4, 100, 30)];
			}
			
		}

		UITextField *txt_cell = (UITextField *)[cell.contentView viewWithTag:1];
		UIButton *btnSelectDOB = (UIButton *)[cell.contentView viewWithTag:2];
		CustomSegmentView *seg_control = (CustomSegmentView *)[cell.contentView viewWithTag:3];
		
		txt_cell.userInteractionEnabled = YES;
		btnSelectDOB.userInteractionEnabled = NO;
		seg_control.hidden = YES;
		
	txt_cell.text = @"";
		switch (indexPath.row) {
			case 0:
				btnSelectDOB.userInteractionEnabled = NO;
				txt_cell.placeholder = @"First Name";
				if ([dictData objectForKey:@"txtTykeFirstName"]) {
					txt_cell.text = [dictData objectForKey:@"txtTykeFirstName"];
				}
				break;
			case 1:
				btnSelectDOB.userInteractionEnabled = NO;
				txt_cell.placeholder = @"Last Name";
				if ([dictData objectForKey:@"txtTykeLastName"]) {
					txt_cell.text = [dictData objectForKey:@"txtTykeLastName"];
				}
				break;
			case 2:
				txt_cell.userInteractionEnabled = NO;
				btnSelectDOB.userInteractionEnabled = YES;
				txt_cell.placeholder = @"Birthday";
				if ([dictData objectForKey:@"txtBirthDate"]) {
					NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
					[formatter setDateFormat:@"yyyy-MM-dd"];
					NSDate *date = [formatter dateFromString:[dictData objectForKey:@"txtBirthDate"]];
					[formatter setDateStyle:NSDateFormatterLongStyle];
					txt_cell.text = [formatter stringFromDate:date];
					[formatter release];
				}
				break;
			case 3:
				btnSelectDOB.userInteractionEnabled = NO;
				txt_cell.userInteractionEnabled = NO;
				seg_control.hidden = NO;
				txt_cell.placeholder = @"Tyke Is a";
				break;
			default:
				break;
		}
		
		cell.tag = indexPath.row;		
	return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark UITableViewCell Buttons


- (void) segementIndexChanged : (CustomSegmentView*) sender callAPI:(BOOL)callAPI {
	CustomSegmentView *seg_cont = (CustomSegmentView*)sender;
	UITableViewCell *cell = (UITableViewCell *)[[seg_cont superview] superview];
	NSIndexPath *ind = [self.regStepTwoTV indexPathForCell:cell];
	
	currentSectionIndex = ind.section;
	
	NSMutableDictionary *dictCurr = [self.dictTykeData objectForKey:[NSString stringWithFormat:@"%d", currentSectionIndex]];
	int index = seg_cont.selectedIndex;
	if (index == 1) {
		[dictCurr setObject:@"M" forKey:@"gender"];
	}else if (index == 2)  {
		[dictCurr setObject:@"F" forKey:@"gender"];
	}
	
	if ([self isFormValid:dictCurr]) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}else {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void) editingStart : (id) sender {
	
	UITextField *textField = (UITextField*)sender;
	CGRect textFieldRect = [self.regStepTwoTV convertRect:textField.bounds fromView:textField];
	CGRect viewRect = [self.regStepTwoTV convertRect:self.regStepTwoTV.bounds fromView:self.regStepTwoTV];
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
	
	CGRect viewFrame = self.regStepTwoTV.frame;
	viewFrame.origin.y -= animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
	[self.regStepTwoTV setFrame:viewFrame];
	
	[UIView commitAnimations];
}

- (void) nextPressed : (id) sender {
	
	UITextField *field = (UITextField*)sender;
	[field resignFirstResponder];
	UITableViewCell *cell = (UITableViewCell *)[[field superview] superview];
	UITableViewCell *nextCell;
	int currTag = cell.tag;
	if (currTag==0) {
		nextCell = [self.regStepTwoTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:numberOfSections]];
		if (nextCell) {
			[[nextCell.contentView viewWithTag:1] becomeFirstResponder];
		}
	}else if (currTag==1) {
		nextCell = [self.regStepTwoTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:numberOfSections]];
		if (nextCell) {
			[[nextCell.contentView viewWithTag:1] becomeFirstResponder];
		}
	}else if (currTag==2) {
	nextCell = [self.regStepTwoTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
	if (nextCell) {
		[[nextCell.contentView viewWithTag:1] becomeFirstResponder];
	}
}

}

- (void) editingEnded : (id) sender {
	
	UITextField *field = (UITextField*)sender;
	UITableViewCell *cell = (UITableViewCell *) [[field superview] superview];
//	if (cell && [cell isKindOfClass:[UITableViewCell class]]) {
//		numberOfSections = [(UITableViewCell*)cell tag];
//	}
	NSIndexPath *ind = [self.regStepTwoTV indexPathForCell:cell];
	currentSectionIndex = ind.section;
	int currTag = cell.tag;
	NSMutableDictionary *dictCurr = [self.dictTykeData objectForKey:[NSString stringWithFormat:@"%d", currentSectionIndex]];
	if (currTag ==0) {
			[dictCurr setObject:DefaultStringValue(field.text) forKey:@"txtTykeFirstName"];
	}else if (currTag == 1) {
			[dictCurr setObject:DefaultStringValue(field.text) forKey:@"txtTykeLastName"];
	}
	CGRect viewFrame = [self.regStepTwoTV frame];
	viewFrame.origin.y += animatedDistance;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[self.regStepTwoTV setFrame:viewFrame];
	[UIView commitAnimations];
	[sender resignFirstResponder];
	
	if ([self isFormValid:dictCurr]) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}else {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void) btnEditPressed : (id) sender {
	
	[self.regStepTwoTV setEditing:!self.regStepTwoTV.editing animated:YES];
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
	
	UIView *DateView = [[DELEGATE window] viewWithTag:121121];
	UIDatePicker *DatePick = (UIDatePicker*)[DateView viewWithTag:111];
	NSDate *selectedDate = DatePick.date;
	NSMutableDictionary *dictCurr = [self.dictTykeData objectForKey:[NSString stringWithFormat:@"%d", currentSectionIndex]];
	if([selectedDate timeIntervalSinceNow] < 0){
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		[dictCurr setObject:[formatter stringFromDate:selectedDate] forKey:@"txtBirthDate"];		
		[formatter release];
		[self cancelDate:nil];
		[self.regStepTwoTV reloadData];
	}else{
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:MSG_ERROR_VALID_BIRTHDATE2
													   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
	if ([self isFormValid:dictCurr]) {
		self.navigationItem.rightBarButtonItem.enabled = YES;
	}else {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
}

- (void) selBirthDate: (id) sender {
	
	UIButton *btn = (UIButton*)sender;
	UITableViewCell *cell = (UITableViewCell *)[[btn superview] superview];
	
	NSIndexPath *ind = [self.regStepTwoTV indexPathForCell:cell];
	currentSectionIndex = ind.section;
	
	[self.view endEditing:YES];
	UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 265, 320, 300)];
	pickerView.datePickerMode = UIDatePickerModeDate;
	pickerView.tag = 111;
	
	UIView *objView = [[UIView alloc] initWithFrame:CGRectMake(0, 480, 320, 480)];
	objView.tag = 121121;
	objView.backgroundColor = [UIColor clearColor];
	[objView addSubview:pickerView];
	[pickerView release];
	
	UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 221, 320, 44)];
	bar.tintColor = [UIColor blackColor];
	bar.tag = 111;
	bar.alpha = 0.8;
	
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

- (void) funAddMoreTyke : (id) sender {
	
	int Flag=1;
	for (int i = 0; i <= [self.dictTykeData count]; i++) {
		NSMutableDictionary *dictCurr = [self.dictTykeData objectForKey:[NSString stringWithFormat:@"%d", i]];
		if ([[dictCurr objectForKey:@"status"] isEqualToString:@"watingToUpload"]) {
			NSString *strError;
			Flag = 0;
			
			if (!([[dictCurr objectForKey:@"txtTykeFirstName"] length] > 0)) {
				strError = MSG_ERROR_VALID_NAME5;
				Flag = 1;
			}else if(!([[dictCurr objectForKey:@"txtTykeLastName"] length] > 0)) {
				strError = MSG_ERROR_VALID_NAME4;
				Flag = 1;
			}else if (![[dictCurr objectForKey:@"txtBirthDate"] length] > 0) {
				strError = MSG_ERROR_VALID_BIRTHDATE1;
				Flag = 1;
			}else if (![[dictCurr objectForKey:@"gender"] length] > 0) {
				strError = MSG_ERROR_VALID_GENDER;
				Flag = 1;
			}
			
			if (Flag) {
				
				if ([[dictCurr objectForKey:@"txtTykeFirstName"] length] > 0) {
					strError = [strError stringByAppendingString:[NSString stringWithFormat:@" of %@", [dictCurr objectForKey:@"txtTykeFirstName"]]];
				}else {
					strError = [strError stringByAppendingString:[NSString stringWithFormat:@" of your tyke"]];
				}
				
				UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Error!" 
																   message:[NSString stringWithFormat:@"%@",strError] 
																  delegate:self 
														 cancelButtonTitle:nil otherButtonTitles:@"Try Again",nil];
				[objAlert show];
				[objAlert release];
			}
		}
	}
	
	if(!Flag) {
		NSMutableDictionary *dictData = [self.dictTykeData objectForKey:[NSString stringWithFormat:@"%d",numberOfSections]];
		if (!dictData) {
			dictData = [[NSMutableDictionary alloc] init];
			[dictData setObject:@"watingToUpload" forKey:@"status"];
			[dictData setObject:@"M" forKey:@"gender"];
			[self.dictTykeData setObject:dictData forKey:[NSString stringWithFormat:@"%d", numberOfSections]];
			[dictData release];
		}
		
		numberOfSections +=1;
		[self.regStepTwoTV  performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];//insertSections:[NSIndexSet indexSetWithIndex:numberOfSections-1] withRowAnimation:UITableViewRowAnimationBottom];
	}		
}

- (void) funBackButtonClicked : (id) sender {
	
	[UIView  beginAnimations:@"Showinfo"context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:0.75];
	[self.navigationController popViewControllerAnimated:YES];
	[UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.navigationController.view cache:NO];
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark - TykeKnitApi Delegate Methods

- (void) addKidResponse : (NSData*)data {
	
	BOOL success = NO;
	NSDictionary *response = [[data stringValue] JSONValue];
		if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		success = YES;
		[DELEGATE removeLoadingView:self.vi_main];
		
		NSString *keyToRemove = nil;
		NSMutableDictionary *dictCurr = nil;
		for (NSString *key in [self.dictTykeData allKeys]) {
			
			dictCurr = [self.dictTykeData objectForKey:key];
			if ([[dictCurr objectForKey:@"status"] isEqualToString:@"uploading"]) {
				keyToRemove = key;
				break;
			}
		}
		if ([self.navigationController isEqual:[DELEGATE nav_Settings]]) {
			NSMutableDictionary *dict_userInfo = [DELEGATE getUserDetails];
			NSMutableArray *arr_tykes = [dict_userInfo objectForKey:@"Kids"];

			NSMutableDictionary *dictTyke = [[NSMutableDictionary alloc]init];
			[dictTyke setObject:[dictCurr objectForKey:@"txtTykeFirstName"] forKey:@"firstName"];
			[dictTyke setObject:[dictCurr objectForKey:@"txtTykeLastName"] forKey:@"lastName"];
			[dictTyke setObject:[dictCurr objectForKey:@"txtBirthDate"] forKey:@"DOB"];
			[dictTyke setObject:[dictCurr objectForKey:@"gender"] forKey:@"gender"];
			[arr_tykes addObject:dictTyke];
			[dictTyke release];
			
			[dict_userInfo writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"] atomically:NO];
		}
		[self.dictTykeData removeObjectForKey:keyToRemove];
		
		NSMutableDictionary *dictCurr1 = nil;
		wantToAddmorechild = NO;
		for (NSString *key in [self.dictTykeData allKeys]) {
			dictCurr1 = [self.dictTykeData objectForKey:key];
			if ([[dictCurr1 objectForKey:@"status"] isEqualToString:@"watingToUpload"]) {
				wantToAddmorechild = YES;
				break;
			}
		}
		
		if (wantToAddmorechild) {
			[DELEGATE addLoadingView:self.vi_main];
			
			[dictCurr1 setObject:@"uploading" forKey:@"status"];
			if ([dictCurr1 objectForKey:@"txtTykeFirstName"] && [dictCurr1 objectForKey:@"txtTykeLastName"] && [dictCurr1 objectForKey:@"txtBirthDate"] && [dictCurr1 objectForKey:@"gender"]) {
				[api_tyke addKid:[dictCurr1 objectForKey:@"txtTykeFirstName"] 
						lastName:[dictCurr1 objectForKey:@"txtTykeLastName"] 
							 DOB:[dictCurr1 objectForKey:@"txtBirthDate"] 
						   photo:[NSString stringWithFormat:@"photo"] 
						  gender:[dictCurr1 objectForKey:@"gender"]
				 ];
			}
		}else {
			if ([self.navigationController isEqual:[DELEGATE nav_login]]) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" 
																message:TITLE_ALERT_KID 
															   delegate:self 
													  cancelButtonTitle:@"Skip" 
													  otherButtonTitles:@"Add Now",nil];
				[alert setDelegate:self];
				[alert setTag:300];
				[alert show];
				[alert release];
			}
			else {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations" 
																message:@"Kids Added Successfully" 
															   delegate:self 
													  cancelButtonTitle:@"Ok" 
													  otherButtonTitles:nil];
				[alert setTag:302];
				[alert show];
				[alert release];
			}
		}
	}
	
	if (!success) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
														message:MSG_ERROR_VALID_REGISTER1
													   delegate:self 
											  cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}

}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag == 300) {
		if (buttonIndex == 1) {
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			
//			userAuthentication *user = [[userAuthentication alloc] initWithNibName:@"userAuthentication" bundle:nil];
//			user.prevContImage = currentImage;
//			[self.navigationController pushViewController:user animated:NO];
//			[user release];
			FriendsMainViewController *frdsVC = [[FriendsMainViewController alloc] initWithNibName:@"FriendsMainViewController" bundle:nil ];
			frdsVC.prevContImage = currentImage;
			[self.navigationController pushViewController:frdsVC animated:NO];
			[frdsVC release];
		}else {
			
			if (![[self.ParentsData objectForKey:@"AccountConfirmationFlag"] intValue]) {
				UIImage *currentImage = [self captureScreen];
				[self pushingViewController:currentImage];
				[DELEGATE userLoggedInWithDict:[DELEGATE dict_userInfo]];
//				[api_tyke resendConfirmationURL];
			}else { //should not come here !
				UIImage *currentImage = [self captureScreen];
				[self pushingViewController:currentImage];
				[DELEGATE userLoggedInWithDict:[DELEGATE dict_userInfo]];
			}
		}
	}else if(alertView.tag == 301) {

		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		
		LoginViewController *login = [[LoginViewController alloc] initWithNibName:@"LoginView" bundle:nil];
		login.prevContImage = currentImage;
		[self.navigationController pushViewController:login animated:NO];
		[login release];
	}else if (alertView.tag == 302) {
		[self popViewController];
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
	
	[self.regStepTwoTV release];
    [super dealloc];
}

@end
