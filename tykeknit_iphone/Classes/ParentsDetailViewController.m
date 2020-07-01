    //
//  ParentsDetailViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 13/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//
#define PHOTO_INDENT 74.0
#define NUMBERSPERIOD @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

#import "ParentsDetailViewController.h"
#import "CustomTableViewCell.h"
#import "ChangePasswordViewController.h"
#import "TableCellImageView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Global.h"
#import "CustomSegmentView.h"
#import "JSON.h"
#import "UIImage+Helpers.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 160;


@implementation ParentsDetailViewController
@synthesize theTableView,dict_userData,arr_emails,vi_photoShadow,photoImageView,valuesUpdated,zipCodeChanged;


- (void) viewWillAppear:(BOOL)animated {
	
	[self.theTableView reloadData];
	[super viewWillAppear:animated];
}

- (void) backPressed : (id) sender {
	
	[self popViewController];
}

- (void) doneClicked : (id) sender {

	[self.view endEditing:YES];
	BOOL flag = YES;
	NSString *strError = nil;
	if (![[self.dict_userData objectForKey:@"firstName"] length]) {
		flag = NO;
		strError = @"Please Enter first name";
	}else if (![[self.dict_userData objectForKey:@"lastName"] length]) {
		flag = NO;
		strError = @"Please Enter last name";
/*        
	}else if (![self.dict_userData objectForKey:@"dob"]) {
		flag = NO;
		strError = @"Please enter Date of Birth";
	}else if ([[self.dict_userData objectForKey:@"zipcode"] length]!=5) {
		flag = NO;
		strError = @"Please enter valid zip code";
*/ 
	}else if ([self.dict_userData objectForKey:@"oldPassword"]) {
		if (![[self.dict_userData objectForKey:@"oldPassword"] isEqualToString:[[DELEGATE dict_userInfo] objectForKey:@"password"]]) {
			flag = NO;
			strError = @"password is incorrect";
		}	
		if (![[self.dict_userData objectForKey:@"newPassword"] length]) {
			flag = NO;
			strError = @"invalid new password";
		}
	}
	if (!flag) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!"
													   message:strError
													  delegate:self 
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	if (flag) {
		if (![self.dict_userData objectForKey:@"imgFile"]) {
			[self.dict_userData setObject:@"" forKey:@"imgFile"];
			[self.dict_userData setObject:@"" forKey:@"picURL"];
		}
        else {
            [self.dict_userData setObject:[self.dict_userData objectForKey:@"imgFile"] forKey:@"picURL"];
        }
		if (self.valuesUpdated) {
			[DELEGATE addLoadingView:[DELEGATE window]];
			[api_tyke updateUserProfile:[self.dict_userData objectForKey:@"firstName"]
							txtLastName:[self.dict_userData objectForKey:@"lastName"]
							txtPassword:[self.dict_userData objectForKey:@"newPassword"]
								 txtDOB:[self.dict_userData objectForKey:@"dob"]
								imgFile:[self.dict_userData objectForKey:@"imgFile"]
						  txtParentType:[self.dict_userData objectForKey:@"gender"]
							 txtZipCode:[self.dict_userData objectForKey:@"zipcode"]];
		}
	}
}

- (void) updateUserProfileResponse:(NSData *)data {

	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
        /*    
		if (self.zipCodeChanged) {
			[api_tyke getLatLongFromZipCode:[self.dict_userData objectForKey:@"zipcode"]];
		}

		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!"
													   message:@"Profile Updated Successfully"
													  delegate:self 
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	*/
		NSMutableDictionary *userDetails = [DELEGATE getUserDetails];
		[userDetails setObject:self.dict_userData forKey:@"userDetails"];
		[userDetails writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"] atomically:NO];
		NSString *picUrl = [self.dict_userData objectForKey:@"picURL"];
		if (picUrl) {
			picUrl = [NSString stringWithFormat:@"%@%@", api_tyke.domain_URL, picUrl];
			[DELEGATE removeFromDocDirFileName:md5(picUrl)];
		}
		[[[DELEGATE dict_userInfo] objectForKey:@"response"] setObject:[self.dict_userData objectForKey:@"picURL"] forKey:@"picURL"];
		[[NSNotificationCenter defaultCenter] postNotificationName:PROFILE_PIC_CHANGED object:self userInfo:nil];
	}else {
	}
    [DELEGATE removeLoadingView:[DELEGATE window]];
}

- (void) latLonRecivedFormZipCode: (NSData*) data {

	NSDictionary *response = [[data stringValue] JSONValue];
	BOOL success = NO;
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		
		id dictZip = [[response objectForKey:@"response"] objectForKey:@"zipGeoLoc"];
		if (dictZip && [dictZip isKindOfClass:[NSDictionary class]]) {
			success = YES;
			[[[DELEGATE dict_userInfo] objectForKey:@"response"] setObject:dictZip forKey:@"zipGeoLoc"];
		}else {
			[[[DELEGATE dict_userInfo] objectForKey:@"response"] removeObjectForKey:@"zipGeoLoc"];
		}
	[DELEGATE removeLoadingView:[DELEGATE window]];		
		[[DELEGATE dict_userInfo] writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userInfo.plist"] atomically:NO];
		[[NSNotificationCenter defaultCenter] postNotificationName:ZIP_CODE_CHANGED object:self userInfo:nil];
	}
	
	if (success) {
		/* UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!"
													   message:@"Profile Updated Successfully"
													  delegate:self 
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release]; */
	}else {
		
	}

}

- (void) deleteUserPicResponse: (NSData*) data {
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		[DELEGATE removeLoadingView:self.vi_main];
		[self.dict_userData removeObjectForKey:@"picURL"];
		[self.dict_userData removeObjectForKey:@"imgFile"];
        isImageSet = FALSE;
//		NSMutableDictionary *userDetails = [DELEGATE getUserDetails];
//		[userDetails setObject:self.dict_userData forKey:@"userDetails"];
//		[userDetails writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"] atomically:NO];
		
		[self.theTableView reloadData];
	}
}


- (void) viewDidLoad {
	
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	UIButton *btn_edit = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	[btn_edit addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_edit] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Profile"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];

	if ([self.dict_userData objectForKey:@"picURL"]) {
		isImageSet = TRUE;
	}
	self.valuesUpdated = NO;
	self.zipCodeChanged = NO;
	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate =self;
	animatedDistance = 0.0f;
	[super viewDidLoad];
}

#pragma mark -
#pragma mark TableView Delegate Methods

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	if (section == 0) {
		return 1;
	}else if (section == 1) {
		return 4;
	}
		return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 53;
	}
	return 40;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 35;
	}
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *view_ForHeader = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 150, 20)];
	return [view_ForHeader autorelease];
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
			
			TableCellImageView *img_view = [[TableCellImageView alloc] initWithFrame:CGRectMake(13, 7, 40, 40)];
			img_view.defaultImage = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
			img_view.tag = 1;
			[cell.contentView addSubview:img_view];
			[img_view release];
			
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(80, 15, 280, 24)];
			lblFirstName.tag = 2;
			lblFirstName.text = @"Change Picture";
			lblFirstName.textColor = [UIColor colorWithRed:0.298 green:0.341 blue:0.420 alpha:1.0];
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font = [UIFont boldSystemFontOfSize:16];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
		}
		
		
		TableCellImageView *img_view = (TableCellImageView *)[cell.contentView viewWithTag:1];
		if ([self.dict_userData objectForKey:@"imgFile"]) {
			[img_view setImage:[UIImage imageWithContentsOfFile:[self.dict_userData objectForKey:@"imgFile"]]];
		}else {
			[img_view setImageUrl:[self.dict_userData objectForKey:@"picURL"]];
		}


		
		return cell;
	}else if (sectionInd == 1) {
		NSString *birthDayCell = @"OtherInfoCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:birthDayCell];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:birthDayCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			UILabel *lblProfileField = [[UILabel alloc] initWithFrame:CGRectMake(20, 4, 127, 30)];
			lblProfileField.textAlignment = UITextAlignmentLeft;
			lblProfileField.tag = 1001;
			lblProfileField.textColor = [UIColor colorWithRed:0.298 green:0.341 blue:0.420 alpha:1.0];
			lblProfileField.backgroundColor = [UIColor clearColor];
			lblProfileField.font = [UIFont boldSystemFontOfSize:16];
			[cell.contentView addSubview:lblProfileField];
			[lblProfileField release];
			
			UITextField *txt_email = [[UITextField alloc] initWithFrame:CGRectMake(145, 10, 108, 20)];
			txt_email.userInteractionEnabled = YES;
			txt_email.textAlignment = UITextAlignmentLeft;
			txt_email.textColor =[UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];
			[txt_email addTarget:self action:@selector(editingStart:) forControlEvents:UIControlEventEditingDidBegin];
			[txt_email addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[txt_email addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			txt_email.autocorrectionType = UITextAutocorrectionTypeNo;
			txt_email.tag = 1002;
			txt_email.backgroundColor = [UIColor clearColor];
			txt_email.font = [UIFont systemFontOfSize:14];
			[cell.contentView addSubview:txt_email];
			[txt_email release];
			
			UIButton *btnSelectDOB = [UIButton buttonWithType:UIButtonTypeCustom];
			btnSelectDOB.tag = 1003;
			btnSelectDOB.backgroundColor = [UIColor clearColor];
			btnSelectDOB.frame = CGRectMake(145, 7, 150, 30);
			[btnSelectDOB addTarget:self action:@selector(selBirthDate:) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:btnSelectDOB];
			
			
			NSMutableArray *arr_segments = [[NSMutableArray alloc]init];
			
			NSMutableDictionary *dict_boy = [[NSMutableDictionary alloc]init];
			[dict_boy setObject:@"index1.png" forKey:@"imageName"];
			[dict_boy setObject:@"Dad" forKey:@"title"];
			[arr_segments addObject:dict_boy];
			[dict_boy release];
			
			NSMutableDictionary *dict_girl = [[NSMutableDictionary alloc]init];
			[dict_girl setObject:@"index2.png" forKey:@"imageName"];
			[dict_girl setObject:@"Mom" forKey:@"title"];
			[arr_segments addObject:dict_girl];
			[dict_girl release];
			
			CustomSegmentView *seg_control = [[CustomSegmentView alloc]initWithFrame:CGRectMake(130, 5, 118, 28) withSegments:[arr_segments autorelease] defaultImage:@"clear" andDelegate:self];
			seg_control.tag = 1004;
			[cell.contentView addSubview:seg_control];
			[seg_control release];
			
		}
		
		CustomSegmentView *seg_cont = (CustomSegmentView*)[cell.contentView viewWithTag:1004];
		UITextField *txt_email = (UITextField *)[cell.contentView viewWithTag:1002];
		UILabel *lblProfileField = (UILabel *)[cell.contentView viewWithTag:1001];
		UIButton *btnSelectDOB = (UIButton *)[cell.contentView viewWithTag:1003];
		
		btnSelectDOB.hidden = YES;
		seg_cont.hidden = YES;
		
		switch (indexPath.row) {
			case 0:
				lblProfileField.text = @"First Name :";
				if ([self.dict_userData objectForKey:@"firstName"]) {
					txt_email.text = [self.dict_userData objectForKey:@"firstName"];
				}
				break;
			case 1:
				lblProfileField.text = @"Last Name :";
				if ([self.dict_userData objectForKey:@"lastName"]) {
					txt_email.text = [self.dict_userData objectForKey:@"lastName"];
				}
				break;
/*                
			case 2:
				lblProfileField.text = @"Date Of Birth :";
				btnSelectDOB.hidden = NO;
				if ([self.dict_userData objectForKey:@"dob"]) {
					NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
					[formatter setDateFormat:@"yyyy-MM-dd"];
					NSDate *date = [formatter dateFromString:[self.dict_userData objectForKey:@"dob"]];
					[formatter setDateStyle:NSDateFormatterMediumStyle];
					NSString *txtdate = [formatter stringFromDate:date];
					txt_email.text = txtdate;
					[formatter release];
				}
				break;
			case 3:
				lblProfileField.text =@"I am a: ";
				seg_cont.hidden = NO;
				if ([[self.dict_userData objectForKey:@"gender"] isEqualToString:@"Dad"]) {
					seg_cont.selectedIndex = 1;
				}else if ([[self.dict_userData objectForKey:@"gender"] isEqualToString:@"Mom"]) {
					seg_cont.selectedIndex = 2;
				} else {
					seg_cont.selectedIndex = -1;
				}

				break;
			case 4:
				lblProfileField.text = @"Password:";
				txt_email.userInteractionEnabled = NO;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				if ([self.dict_userData objectForKey:@"newPassword"]) {
					txt_email.text = [self.dict_userData objectForKey:@"newPassword"];
					txt_email.secureTextEntry = YES;
				}
				break;
			case 5:
				lblProfileField.text = @"Zip Code:";
				if ([self.dict_userData objectForKey:@"zipcode"]) {
					txt_email.text =[self.dict_userData objectForKey:@"zipcode"];
					txt_email.keyboardType = UIKeyboardTypeNumberPad;
					txt_email.delegate = self;
					[txt_email addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
				}
				break;
*/
            case 2:
				lblProfileField.text =@"I am a: ";
				seg_cont.hidden = NO;
				if ([[self.dict_userData objectForKey:@"gender"] isEqualToString:@"Dad"]) {
					seg_cont.selectedIndex = 1;
				}else if ([[self.dict_userData objectForKey:@"gender"] isEqualToString:@"Mom"]) {
					seg_cont.selectedIndex = 2;
				} else {
					seg_cont.selectedIndex = -1;
				}
                
				break;

			case 3:
				lblProfileField.text = @"Password:";
				txt_email.userInteractionEnabled = NO;
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				if ([self.dict_userData objectForKey:@"newPassword"]) {
					txt_email.text = [self.dict_userData objectForKey:@"newPassword"];
					txt_email.secureTextEntry = YES;
				}
				break;
			
            default:
				break;
		}
		
		cell.tag = indexPath.row;
		return cell;
	}
	return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section == 0) {
		[self selectImage];
	}else {
		if (indexPath.row == 3) {
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			
			ChangePasswordViewController *change = [[ChangePasswordViewController alloc]initWithNibName:@"ChangePasswordViewController" bundle:nil];
			change.dict_userData = self.dict_userData;
			change.prevContImage = currentImage;
			[self.navigationController pushViewController:change animated:NO];
			[change release];
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark tableview components Methods
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
		ErrorMessage = @"Birth date has to be in the past!";
	}else if (interval > -568080000) {		//timeInterval For 18 years
		ErrorMessage = @"You sholuld have to be more the 18 years";
	}
	
	if (ErrorMessage) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrorMessage 
													   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		[self.dict_userData setObject:[formatter stringFromDate:selectedDate] forKey:@"dob"];
		[formatter release];
		[self cancelDate:nil];
		[self.theTableView reloadData];
	}
}

- (void) selBirthDate: (id) sender {
	
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
	bar.tag = 101;
	bar.barStyle = UIBarStyleBlack;
	bar.tintColor = [UIColor blackColor];
	bar.alpha = 0.8;
	
	
	if ([self.dict_userData objectForKey:@"dob"]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		pickerView.date = [formatter dateFromString:[self.dict_userData objectForKey:@"dob"]];
		[formatter release];
	}
	
	
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


- (void) segementIndexChanged : (CustomSegmentView*) sender callAPI:(BOOL)callAPI {
	CustomSegmentView *seg_cont = (CustomSegmentView *) sender;
	int index = seg_cont.selectedIndex;
	if (index == 1) {
		if ([[self.dict_userData objectForKey:@"gender"] isEqualToString:@"Mom"]) {
			self.valuesUpdated = YES;		
		}
		[self.dict_userData setObject:@"Dad" forKey:@"gender"];
	}else if (index == 2){
		if ([[self.dict_userData objectForKey:@"gender"] isEqualToString:@"Dad"]) {
			self.valuesUpdated = YES;		
		}
		[self.dict_userData setObject:@"Mom" forKey:@"gender"];
	}
}

- (void) segmentChanged : (id) sender {
	
	UISegmentedControl *seg_cont = (UISegmentedControl*)sender;
	int index = seg_cont.selectedSegmentIndex;
	if (index == 0) {
		if ([[self.dict_userData objectForKey:@"gender"] isEqualToString:@"Mom"]) {
			self.valuesUpdated = YES;		
		}
		[self.dict_userData setObject:@"Dad" forKey:@"gender"];
	}else {
		if ([[self.dict_userData objectForKey:@"gender"] isEqualToString:@"Dad"]) {
			self.valuesUpdated = YES;		
		}
		[self.dict_userData setObject:@"Mom" forKey:@"gender"];
	}

}

- (void) editingChanged : (id) sender {
	UITextField *textField = (UITextField*)sender;
	if ([textField.text length]>=5) {
		[textField resignFirstResponder];
	}
}

- (void) editingStart : (id) sender {
	
	UITextField *textField = (UITextField*)sender;
	CGRect textFieldRect = [self.theTableView convertRect:textField.bounds fromView:textField];
	CGRect viewRect = [self.theTableView convertRect:self.theTableView.bounds fromView:self.theTableView];
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
	if ([self.theTableView indexPathForCell:(UITableViewCell *)[[textField superview]superview]].section==3) 
		animatedDistance = 210.0;
	
	
	CGRect viewFrame = self.theTableView.frame;
	viewFrame.origin.y -= animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
	[self.theTableView setFrame:viewFrame];
	[UIView commitAnimations];
}

-(void) nextPressed : (id) sender {
	UITextField *txt_field = (UITextField *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[txt_field superview] superview];
	if ([cell.reuseIdentifier isEqualToString:@"ProfileCell"]) {
		if (txt_field.tag == 1) {
			[(UITextField *)[cell.contentView viewWithTag:2] becomeFirstResponder];
		}
	}else if ([cell.reuseIdentifier isEqualToString:@"PasswordCell"]) {
		if (cell.tag == 0) {
			UITableViewCell *nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
			[(UITextField *)[nextCell.contentView viewWithTag:22] becomeFirstResponder];
		}else if (cell.tag == 1) {
//			UITableViewCell *nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]];
//			[(UITextField *)[nextCell.contentView viewWithTag:32] becomeFirstResponder];
		}
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
				if (![[self.dict_userData objectForKey:@"firstName"] isEqualToString:value]) {
					self.valuesUpdated = YES;					
				}
				[self.dict_userData setObject:DefaultStringValue(value)  forKey:@"firstName"];			
				break;
			case 1:
				if (![[self.dict_userData objectForKey:@"lastName"] isEqualToString:value]) {
					self.valuesUpdated = YES;					
				}
				[self.dict_userData setObject:DefaultStringValue(value) forKey:@"lastName"];
				break;
			case 4:
				if (![[self.dict_userData objectForKey:@"password"] isEqualToString:value]) {
					self.valuesUpdated = YES;					
				}
				[self.dict_userData setObject:DefaultStringValue(value) forKey:@"password"];
				break;
/*                
			case 5:
				if (![[self.dict_userData objectForKey:@"zipcode"] isEqualToString:value]) {
					self.zipCodeChanged = YES;
					self.valuesUpdated = YES;					
				}
				[self.dict_userData setObject:DefaultStringValue(value) forKey:@"zipcode"];
				break;
*/
			default:
				break;
		}
	}
	
	CGRect viewFrame = [self.theTableView frame];
	viewFrame.origin.y += animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[self.theTableView setFrame:viewFrame];
	[UIView commitAnimations];
	
	[sender resignFirstResponder];

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

- (void) selectImage {
	
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
		pc.navigationBar.tag = 101;
		pc.navigationBar.backgroundColor = [UIColor darkGrayColor];
		[DELEGATE putSideViewToBack];
		[self presentModalViewController:pc animated:NO];
		[pc release];
	}else if(buttonIndex == 1) {
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			UIImagePickerController *pc = [[UIImagePickerController alloc] init];
			pc.delegate = self;
			pc.allowsEditing = YES;
			pc.navigationBar.tag = 101;
			pc.mediaTypes = [NSArray arrayWithObjects:(id)kUTTypeImage, nil];
			pc.sourceType = UIImagePickerControllerSourceTypeCamera;
			[DELEGATE putSideViewToBack];
			[self presentModalViewController:pc animated:NO];
			[pc release];
		}else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
															message:@"Camera is not avaliable in this device" 
														   delegate:self 
												  cancelButtonTitle:@"Ok" 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}else {
		if (isImageSet) {
			if (buttonIndex == 2) {
				[DELEGATE addLoadingView:self.vi_main];
				[api_tyke deleteUserPic];
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
	
//	[DELEGATE putSideViewToBack];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyyMMddHHmmss"];
	NSString *strImageName = [NSString stringWithFormat:@"%@.jpg", [formatter stringFromDate:[NSDate date]]];
	isImageSet = TRUE;
	NSData *img_data = UIImageJPEGRepresentation(img, 0.7);
	[img_data writeToFile:[DOC_DIR stringByAppendingPathComponent:strImageName] atomically:NO];
	[self.dict_userData setObject:[DOC_DIR stringByAppendingPathComponent:strImageName] forKey:@"imgFile"];
	//	[photoImageView setImage:img forState:UIControlStateNormal];
	[self.theTableView reloadData];
	[DELEGATE bringSideViewToFront];
	[formatter release];
	self.valuesUpdated = YES;
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	
    [super dealloc];
}

@end
