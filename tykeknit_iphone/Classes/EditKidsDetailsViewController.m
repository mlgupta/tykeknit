//
//  EditKidsDetailsViewController.m
//  TykeKnit
//
//  Created by Ver on 01/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#define PHOTO_INDENT 74.0
#import "EditKidsDetailsViewController.h"
#import "CustomTableViewCell.h"
//#import "UIImage+Helpers.h"
#import "TableCellImageView.h"
#import "JSON.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "CustomSegmentView.h"

@implementation EditKidsDetailsViewController
@synthesize theTableView,child_id,vi_photoShadow,photoImageView,api_tyke,dict_data,valuesUpdated;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 160;


- (void) backPressed : (id) sender {
	[self popViewController];
}

- (void) doneClicked : (id) sender {
	
	[self.view endEditing:YES];
		
	
	BOOL flag = YES;
	NSString *strError = nil;
	if (![[self.dict_data objectForKey:@"firstName"] length]) {
		flag = NO;
		strError = @"Please Enter first name";
	}else if (![[self.dict_data objectForKey:@"lastName"] length]) {
		flag = NO;
		strError = @"Please Enter last name";
	}else if (![self.dict_data objectForKey:@"DOB"]) {
		flag = NO;
		strError = @"Please enter Date of Birth";
	}else if (![[self.dict_data objectForKey:@"gender"] length]) {
		flag = NO;
		strError = @"Please select gender ";
	}
	
	if (!flag) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!"
													   message:strError
													  delegate:self 
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
	NSString *imgFile = nil;	
	if ([self.dict_data objectForKey:@"imgFile"]) {
		imgFile =[self.dict_data objectForKey:@"imgFile"];
	}

	if (flag) {
		if (self.valuesUpdated) {
			[DELEGATE addLoadingView:[DELEGATE window]];
			[api_tyke updateChildProfile:self.child_id 
							txtFirstName:[self.dict_data objectForKey:@"firstName"]
							 txtLastName:[self.dict_data objectForKey:@"lastName"]
								  txtDOB:[self.dict_data objectForKey:@"DOB"]
							   txtGender:[self.dict_data objectForKey:@"gender"] 
								 imgFile:imgFile];
		}
	}
}	

- (void) updateChildProfileResponse:(NSData *)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		/* UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!"
													   message:@"Profile Updated Successfully"
													  delegate:self 
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release]; */
		
		
		NSMutableDictionary *userDetails = [DELEGATE getUserDetails];
		NSMutableArray *arr_tyke = [userDetails objectForKey:@"Kids"];
		for (int i=0;i < [arr_tyke count];i++) {
			if ([[[arr_tyke objectAtIndex:i] objectForKey:@"id"] isEqualToString:[self.dict_data objectForKey:@"id"]]) {
				[arr_tyke removeObjectAtIndex:i];
				[arr_tyke addObject:self.dict_data];
				break;
			}
		}
		
		if ([self.dict_data objectForKey:@"picURL"]) {
			NSString *picUrl = [self.dict_data objectForKey:@"picURL"];
			if (picUrl) {
				picUrl = [NSString stringWithFormat:@"%@%@", api_tyke.domain_URL, picUrl];
				[DELEGATE removeFromDocDirFileName:md5(picUrl)];
			}
		}
		[userDetails writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"] atomically:NO];
	}
	

	[DELEGATE removeLoadingView:[DELEGATE window]];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	UIButton *btn_edit = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	[btn_edit addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_edit] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Profile"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];
	
	self.valuesUpdated = NO;
/*
	self.vi_photoShadow = [[UIView alloc] initWithFrame:CGRectMake(9.0, 0, 64, 64)];
	CALayer *sublayer = self.vi_photoShadow.layer;
	sublayer.backgroundColor = [UIColor clearColor].CGColor;
	sublayer.shadowOffset = CGSizeMake(0, 2);
	sublayer.shadowRadius = 3.0;
	sublayer.shadowOpacity = 1;
*/	
	if ([self.dict_data objectForKey:@"picURL"]) {
		isImageSet = TRUE;
	}
	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate = self;

/*    
	self.photoImageView = [UIButton buttonWithType:UIButtonTypeCustom];
	self.photoImageView.frame = CGRectMake(0.0, 0, 64.0, 64.0);
	[self.photoImageView.layer setCornerRadius:5.0];
	self.photoImageView.layer.masksToBounds = YES;
	[self.photoImageView setClipsToBounds:YES];
	self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
	[self.vi_photoShadow addSubview:photoImageView];
	[photoImageView setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"tyke_knit_default")] forState:UIControlStateNormal];
	[self.photoImageView addTarget:self action:@selector(selectImage:) forControlEvents:UIControlEventTouchUpInside];
*/
	
    [super viewDidLoad];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
//	return 3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (section == 0) {
		return 1;
	}
	if (section == 2) {
		return 1;
	}
	return 4;
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

	UITableViewCell *cell = nil;
	if (sectionInd == 0) {

		NSString *parentInfo = @"parentInfo";
		cell = [tableView dequeueReusableCellWithIdentifier:parentInfo];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:parentInfo] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			TableCellImageView *img_view = [[TableCellImageView alloc] initWithFrame:CGRectMake(13, 7, 40, 40)];
			img_view.defaultImage = [UIImage imageWithContentsOfFile:getImagePathOfName(@"tyke_knit_default")];
			img_view.tag = 1;
			[cell.contentView addSubview:img_view];
			[img_view release];
			
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(80, 15, 280, 24)];
			lblFirstName.tag = 2;
			lblFirstName.text = @"Change Picture";
			lblFirstName.textColor = [UIColor colorWithRed:0.298 green:0.341 blue:0.420 alpha:1.0];
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font = [UIFont boldSystemFontOfSize:17];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
		}
		
		TableCellImageView *img_view = (TableCellImageView *)[cell.contentView viewWithTag:1];
		if ([self.dict_data objectForKey:@"imgFile"]) {
			[img_view setImage:[UIImage imageWithContentsOfFile:[self.dict_data objectForKey:@"imgFile"]]];
		}else {
			[img_view setImageUrl:[self.dict_data objectForKey:@"picURL"]];
		}
		return cell;
	}else if (sectionInd == 1) {
		NSString *CellIdentifier = @"ProfileCell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UILabel *lblProfileField = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, 127, 30)];
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
			[dict_boy setObject:@"Boy" forKey:@"title"];
			[arr_segments addObject:dict_boy];
			[dict_boy release];
			
			NSMutableDictionary *dict_girl = [[NSMutableDictionary alloc]init];
			[dict_girl setObject:@"index2.png" forKey:@"imageName"];
			[dict_girl setObject:@"Girl" forKey:@"title"];
			[arr_segments addObject:dict_girl];
			[dict_girl release];
			
			CustomSegmentView *seg_control = [[CustomSegmentView alloc]initWithFrame:CGRectMake(130, 5, 118, 28) withSegments:[arr_segments autorelease] defaultImage:@"clear" andDelegate:self];
			seg_control.tag = 1004;
			[cell.contentView addSubview:seg_control];
			[seg_control release];
			
		}
		
		CustomSegmentView *seg_cont = (CustomSegmentView*)[cell viewWithTag:1004];
		UITextField *txt_email = (UITextField *)[cell.contentView viewWithTag:1002];
		UILabel *lblProfileField = (UILabel *)[cell.contentView viewWithTag:1001];
		UIButton *btnSelectDOB = (UIButton *)[cell.contentView viewWithTag:1003];
		
		btnSelectDOB.hidden = YES;
		seg_cont.hidden = YES;
		
		switch (indexPath.row) {
			case 0:
				lblProfileField.text = @"First Name :";
				if ([self.dict_data objectForKey:@"firstName"]) {
					txt_email.text = [self.dict_data objectForKey:@"firstName"];
				}
				break;
			case 1:
				lblProfileField.text = @"Last Name :";
				if ([self.dict_data objectForKey:@"lastName"]) {
					txt_email.text = [self.dict_data objectForKey:@"lastName"];
				}
				break;
			case 2:
				lblProfileField.text = @"Date Of Birth :";
				btnSelectDOB.hidden = NO;
				if ([self.dict_data objectForKey:@"DOB"]) {
					NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
					[formatter setDateFormat:@"yyyy-MM-dd"];
					NSDate *date = [formatter dateFromString:[self.dict_data objectForKey:@"DOB"]];
					[formatter setDateStyle:NSDateFormatterMediumStyle];
					NSString *txtdate = [formatter stringFromDate:date];
					txt_email.text = txtdate;
					[formatter release];
				}
				break;
			case 3:
				lblProfileField.text =@"Tyke is a: ";
				seg_cont.hidden = NO;
				if ([[self.dict_data objectForKey:@"gender"] isEqualToString:@"M"]) {
					seg_cont.selectedIndex = 1;
				}else if ([[self.dict_data objectForKey:@"gender"] isEqualToString:@"F"]) {
					seg_cont.selectedIndex = 2;
				} else {
					seg_cont.selectedIndex = -1;
				}
				
				break;
		}				
		
		cell.tag = indexPath.row;
			return cell;
	}else if (sectionInd == 2) {
		NSString *buttonCell = @"buttonCell";
		cell = [tableView dequeueReusableCellWithIdentifier:buttonCell];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:buttonCell] autorelease];
//			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
			UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
			btn.frame = CGRectMake( -3, -1, 270, 45);
			[btn setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_deleteTyke")] forState:UIControlStateNormal];
			[btn addTarget:self action:@selector(deleteTyke:) forControlEvents:UIControlEventTouchUpInside];
			[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
			[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
			[[btn titleLabel] setFont:[UIFont boldSystemFontOfSize:13]];
			btn.tag = 16;
			btn.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:btn];
		}		
		return cell;
	}
		return nil;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section == 0) {
		[self selectImage];
	}
}

- (void) segementIndexChanged : (CustomSegmentView*) sender callAPI:(BOOL)callAPI {
	CustomSegmentView *seg_cont = (CustomSegmentView*)sender;
	int index = seg_cont.selectedIndex;
	if (index == 1) {
		if ([[self.dict_data objectForKey:@"gender"] isEqualToString:@"F"]) {
			self.valuesUpdated = YES;
		}
		[self.dict_data setObject:@"M" forKey:@"gender"];
	}else if (index == 2)  {
		if ([[self.dict_data objectForKey:@"gender"] isEqualToString:@"M"]) {
			self.valuesUpdated = YES;
		}
		[self.dict_data setObject:@"F" forKey:@"gender"];
	}
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
	}
	if (ErrorMessage) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrorMessage 
													   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		if (![[self.dict_data objectForKey:@"DOB"] isEqualToString:[formatter stringFromDate:selectedDate]]) {
			valuesUpdated = YES;
		}
		[self.dict_data setObject:[formatter stringFromDate:selectedDate] forKey:@"DOB"];
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
	bar.tintColor = [UIColor blackColor];
	bar.alpha = 0.8;
	
	if ([self.dict_data objectForKey:@"DOB"]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy-MM-dd"];
		pickerView.date = [formatter dateFromString:[self.dict_data objectForKey:@"DOB"]];
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


- (void) segmentChanged : (id) sender {
	
	UISegmentedControl *seg_cont = (UISegmentedControl*)sender;
	int index = seg_cont.selectedSegmentIndex;
	if (index == 0) {
		if ([[self.dict_data objectForKey:@"gender"] isEqualToString:@"F"]) {
			self.valuesUpdated = YES;
		}
		[self.dict_data setObject:@"M" forKey:@"gender"];
	}else {
		if ([[self.dict_data objectForKey:@"gender"] isEqualToString:@"M"]) {
			self.valuesUpdated = YES;
		}
		[self.dict_data setObject:@"F" forKey:@"gender"];
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
		if (cell.tag == 0) {
			UITableViewCell *nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
			[(UITextField *)[nextCell.contentView viewWithTag:22] becomeFirstResponder];
		}
	[txt_field resignFirstResponder];
}
- (void) editingEnded:(id)sender {
	UITextField *txt_field = (UITextField *)sender;
	NSString *value = txt_field.text;
	UITableViewCell *cell = (UITableViewCell *)[[txt_field superview] superview];
	if ([value length]) {
		if (cell.tag == 0) {
			if (![[self.dict_data objectForKey:@"firstName"] isEqualToString:value]) {
				self.valuesUpdated = YES;
			}
			[self.dict_data setObject:DefaultStringValue(value) forKey:@"firstName"];
		}else if (cell.tag == 1) {
			if (![[self.dict_data objectForKey:@"lastName"] isEqualToString:value]) {
				self.valuesUpdated = YES;
			}
			[self.dict_data setObject:DefaultStringValue(value) forKey:@"lastName"];
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

- (void) deleteTyke:(id) sender {
	NSLog(@"delete tyke");
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
				[api_tyke deleteChildPic:self.child_id];
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
	[self.dict_data setObject:[DOC_DIR stringByAppendingPathComponent:strImageName] forKey:@"imgFile"];
	//	[photoImageView setImage:img forState:UIControlStateNormal];
	[self.theTableView reloadData];
	[DELEGATE bringSideViewToFront];
	[formatter release];
	self.valuesUpdated = YES;
	[self dismissModalViewControllerAnimated:YES];
}

- (void) getChildProfDetailResp : (NSData*) data {
	
	NSMutableDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:[DELEGATE window]];

	self.dict_data = [response objectForKey:@"response"];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		
		[self.theTableView reloadData];
	}else {
		UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
														   message:[[response objectForKey:@"reason"] objectForKey:@"reasonStr"]// MSG_ERROR_VALID_REGISTER4
														  delegate:nil 
												 cancelButtonTitle:@"Ok" 
												 otherButtonTitles:nil];
		[objAlert show];
		[objAlert release];
	}
}

- (void) deleteChildPicResponse : (NSData*) data {
	
	NSMutableDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		[DELEGATE removeLoadingView:self.vi_main];
		[self.dict_data removeObjectForKey:@"picURL"];
		
		NSMutableDictionary *userDetails = [DELEGATE getUserDetails];
		NSMutableArray *arr_tyke = [userDetails objectForKey:@"Kids"];
		for (int i=0;i < [arr_tyke count];i++) {
			if ([[[arr_tyke objectAtIndex:i] objectForKey:@"id"] isEqualToString:[self.dict_data objectForKey:@"id"]]) {
				[arr_tyke removeObjectAtIndex:i];
				[arr_tyke addObject:self.dict_data];
				break;
			}
		}
		
		[userDetails writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"] atomically:NO];
		
		[self.theTableView reloadData];
		
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


- (void)dealloc {
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}

@end
