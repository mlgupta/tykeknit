//
//  PlaydateScheduleDateTimeViewController.m
//  TykeKnit
//
//  Created by Ver on 06/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaydateScheduleDateTimeViewController.h"
#import "Global.h"
#import "Messages.h"


@implementation PlaydateScheduleDateTimeViewController
@synthesize theTableView,dict_scheduleData;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void) cancelPicker : (id) sender {
	[[DELEGATE vi_sideView] setUserInteractionEnabled:YES];
	UIView *dateView = [[DELEGATE window] viewWithTag:121121];
	if (dateView) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:Trans_Duration];
		[dateView setFrame:CGRectMake( 0, 480, 320, 416)];
		[UIView commitAnimations];
		[dateView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:Trans_Duration];
	}
}

-(void) backPressed:(id)sender{
	[self cancelPicker:nil];
	NSString *strError = nil;
	int flag = 1;
	if (![self.dict_scheduleData objectForKey:@"txtEndDate"]) {
		strError = @"You have not selected end date";
		flag = 2;
	}
	if (![self.dict_scheduleData objectForKey:@"txtDate"]) {
		strError = @"You have not selected start date";
			flag = 3;
	}
	
	if (flag == 2) {
		[self.dict_scheduleData removeObjectForKey:@"txtDate"];
	}else if (flag == 3) {
		[self.dict_scheduleData removeObjectForKey:@"txtEndDate"];
	}
	
	if ([[self.dict_scheduleData objectForKey:@"txtDate"] length] && [[self.dict_scheduleData objectForKey:@"txtEndDate"] length]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
		[formatter setDateStyle:NSDateFormatterLongStyle];
		NSDate *startTime = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtDate"]];
		NSDate *endTime = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtEndDate"]];
		[formatter setDateFormat:@"dd-MM-yyyy"];
		NSString *str_time = [formatter stringFromDate:startTime];
		NSString *end_time = [formatter stringFromDate:endTime];
		NSDate *startdate = [formatter dateFromString:str_time];
		NSDate *enddate = [formatter dateFromString:end_time];
		NSTimeInterval diffrence = [startdate timeIntervalSinceDate:enddate];
		if (diffrence == 0) {
			if ([[self.dict_scheduleData objectForKey:@"txtStartTime"] length] && [[self.dict_scheduleData objectForKey:@"txtEndTime"] length]) {
				NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
				[formatter setDateFormat:@"HH:mm:ss"];
				NSDate *startTime = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtStartTime"]];
				NSDate *endTime = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtEndTime"]];
				
				NSTimeInterval diffrence = [startTime timeIntervalSinceDate:endTime];
				if (diffrence > 0) {
					strError = @"Please enter suitable start and end time";
					flag = 11;
				}
				[formatter release];
			}
			
		}
		if (diffrence > 0) {
			strError = @"Please enter suitable start and end date";
			flag = 11;
		}
		[formatter release];
	}
	
	if (flag == 11) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:strError 
													   delegate:self cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else {
		[self popViewController];
	}

}

- (void)viewDidLoad {
	UIButton *btn_back =[DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	[btn_done addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_done] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Playdate Duration"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];

    [super viewDidLoad];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 35;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *view_ForHeader = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 150, 50)];
	 return [view_ForHeader autorelease];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell = nil;
	cell = [tableView dequeueReusableCellWithIdentifier:@"section 0"];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"section 0"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		
//		UILabel *lbl_start1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 75, 20)];
//		lbl_start1.tag = 1;
//		lbl_start1.backgroundColor = [UIColor clearColor];
//		lbl_start1.font = [UIFont fontWithName:@"helvetica Neue" size:14];
//		lbl_start1.font = [UIFont boldSystemFontOfSize:14];
//		lbl_start1.text = @"Starts";
//		lbl_start1.layer.shadowColor = [UIColor whiteColor].CGColor;
//		lbl_start1.layer.shadowOffset = CGSizeMake(0, 2);
//		lbl_start1.layer.shadowRadius = 2.0;
//		lbl_start1.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
//		lbl_start1.textColor = [UIColor darkTextColor];
//		[cell.contentView addSubview:lbl_start1];
//		[lbl_start1 release];
//		
//		UILabel *lbl_start2 = [[UILabel alloc]initWithFrame:CGRectMake(125, 10, 125, 20)];
//		lbl_start2.tag = 2;
//		lbl_start2.textAlignment = UITextAlignmentRight;
//		lbl_start2.font = [UIFont fontWithName:@"helvetica Neue" size:13];
//		lbl_start2.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
//		[lbl_start2 setBackgroundColor:[UIColor clearColor]];
//		[cell.contentView addSubview:lbl_start2];
//		[lbl_start2 release];
//		
//		UIButton *btn_startTime = [UIButton buttonWithType:UIButtonTypeCustom];
//		btn_startTime.frame = CGRectMake(60, 10, 185, 20);
//		btn_startTime.tag = 3;
//		btn_startTime.backgroundColor = [UIColor clearColor];
//		[cell.contentView addSubview:btn_startTime];
	}
	
//	UILabel *lbl_start1 = (UILabel *)[cell.contentView viewWithTag:1];
//	UILabel *lbl_start2 = (UILabel *)[cell.contentView viewWithTag:2];
//	UIButton *btn_startTime = (UIButton *)[cell.contentView viewWithTag:3];
//	UISwitch *switch_allDay = (UISwitch *)[cell.contentView viewWithTag:4];

//	btn_startTime.hidden = YES;
//	switch_allDay.hidden = YES;
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Starts";
			//btn_startTime.hidden = NO;
			//[btn_startTime addTarget:self action:@selector(selectStartDate:) forControlEvents:UIControlEventTouchUpInside];
			if ([self.dict_scheduleData objectForKey:@"txtDate"] && [self.dict_scheduleData objectForKey:@"txtStartTime"]) {
				NSString *str_date = [self.dict_scheduleData objectForKey:@"txtDate"];
				NSArray *arr = [str_date componentsSeparatedByString:@","];
				NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
				[formatter setDateFormat:@"HH:mm:ss"];
				NSDate *dt = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtStartTime"]];
				[formatter setDateFormat:@"hh:mm a"];
				NSString *startTime = [formatter stringFromDate:dt];
				[formatter release];

				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",[arr objectAtIndex:0],startTime];
			}
			break;
		case 1:
			cell.textLabel.text = @"Ends";
//			[btn_startTime addTarget:self action:@selector(selectEndDate:) forControlEvents:UIControlEventTouchUpInside];
			if ([self.dict_scheduleData objectForKey:@"txtEndTime"] && [self.dict_scheduleData objectForKey:@"txtEndDate"]) {
				NSString *str_date = [self.dict_scheduleData objectForKey:@"txtEndDate"];
				NSArray *arr = [str_date componentsSeparatedByString:@","];

				NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
				[formatter setDateFormat:@"HH:mm:ss"];
				NSDate *dt = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtEndTime"]];
				[formatter setDateFormat:@"hh:mm a"];
				NSString *startTime = [formatter stringFromDate:dt];
				[formatter release]; 
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",[arr objectAtIndex:0],startTime];
			}
			break;
		default:
			break;
	}
	return cell;
}

- (void) selectStartDate:(id) sender {
	[self showPickerFor:@"startDate"];
}

- (void) selectEndDate : (id) sender {
	[self showPickerFor:@"endDate"];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self selectStartDate:nil];
    } else if (indexPath.row == 1) {
        [self selectEndDate:nil];
    }
}


- (void) datePickerValueChanged : (id) sender {
	UIDatePicker *pickerView = (UIDatePicker *)sender;

	if (pickerView.tag == 111) {
		NSDate *selectedDate = pickerView.date;
		NSTimeInterval interval = [selectedDate timeIntervalSinceNow];
		
		NSString *ErrorMessage = nil;
		if (interval < 0) {
			ErrorMessage =MSG_ERROR_VALID_PLAYDATE1;
		}
		if (ErrorMessage) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrorMessage 
														   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}else {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtDate"];
			[formatter setDateFormat:@"HH:mm:ss"];
			[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtStartTime"];
			[formatter release];
//			[self cancelPicker:nil];
//			[self.theTableView reloadData];
		}
		if ([self.dict_scheduleData objectForKey:@"txtDate"] && [self.dict_scheduleData objectForKey:@"txtStartTime"]) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			NSDate *dt1 = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtDate"]];
			
			[formatter setDateFormat:@"dd-MM-yyyy"];
			NSString *str = [formatter stringFromDate:dt1];
			
			[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
			NSString *str_date = [NSString stringWithFormat:@"%@ %@",str,[self.dict_scheduleData objectForKey:@"txtStartTime"]];
			NSDate *dt = [formatter dateFromString:str_date];
			pickerView.date = dt;
			[formatter release];
		}
	}else if (pickerView.tag == 112) {
		
		NSDate *selectedDate = pickerView.date;
		NSTimeInterval interval = [selectedDate timeIntervalSinceNow];
		
		NSString *ErrorMessage = nil;
		if (interval < 0) {
			ErrorMessage =MSG_ERROR_VALID_PLAYDATE1;
		}
		if (ErrorMessage) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrorMessage 
														   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}else {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtEndDate"];
			[formatter setDateFormat:@"HH:mm:ss"];
			[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtEndTime"];
			[formatter release];
			
//			[self cancelPicker:nil];
//			[self.theTableView reloadData];
		}

		if ([self.dict_scheduleData objectForKey:@"txtEndDate"] && [self.dict_scheduleData objectForKey:@"txtEndTime"]) {
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			NSDate *dt1 = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtEndDate"]];
			
			[formatter setDateFormat:@"dd-MM-yyyy"];
			NSString *str = [formatter stringFromDate:dt1];
			
			[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
			NSString *str_date = [NSString stringWithFormat:@"%@ %@",str,[self.dict_scheduleData objectForKey:@"txtEndTime"]];
			NSDate *dt = [formatter dateFromString:str_date];
			pickerView.date = dt;
			[formatter release];
		}else if([self.dict_scheduleData objectForKey:@"txtDate"] && [self.dict_scheduleData objectForKey:@"txtStartTime"]) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			NSDate *dt1 = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtDate"]];
			
			[formatter setDateFormat:@"dd-MM-yyyy"];
			NSString *str = [formatter stringFromDate:dt1];
			
			[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
			NSString *str_date = [NSString stringWithFormat:@"%@ %@",str,[self.dict_scheduleData objectForKey:@"txtStartTime"]];
			NSDate *dt = [formatter dateFromString:str_date];
			pickerView.date = dt;
			[formatter release];
		}
	}else if (pickerView.tag == 113) {
		NSDate *selectedDate = pickerView.date;
		NSTimeInterval interval = [selectedDate timeIntervalSinceNow];
		
		NSString *ErrorMessage = nil;
		if (interval < 0) {
			ErrorMessage =MSG_ERROR_VALID_PLAYDATE1;
		}
		if (ErrorMessage) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrorMessage 
														   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
		}else {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtDate"];
			[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtEndDate"];
			[formatter setDateFormat:@"HH:mm:ss"];
			[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtStartTime"];
			[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtEndTime"];
			[formatter release];
			
			//			[self cancelPicker:nil];
			//			[self.theTableView reloadData];
		}
		
	}
	[self.theTableView reloadData];
}
- (void) switchChanged : (id) sender {
	UISwitch *sw_allDay = (UISwitch *)sender;
	UIDatePicker *pickerView = nil;
	if ([[DELEGATE window] viewWithTag:121121]) {
		pickerView = (UIDatePicker *)[[[DELEGATE window] viewWithTag:121121] viewWithTag:111];
		if (!pickerView) {
			pickerView = (UIDatePicker *)[[[DELEGATE window] viewWithTag:121121] viewWithTag:112];
		}
		if ([sw_allDay isOn]) {
			pickerView.datePickerMode = UIDatePickerModeDate;
		}else {
			pickerView.datePickerMode = UIDatePickerModeDateAndTime;
		}
	}
	pickerView.tag == 113;
	NSDate *selectedDate = pickerView.date;
	NSTimeInterval interval = [selectedDate timeIntervalSinceNow];
	NSString *ErrorMessage = nil;
	if (interval < 0) {
		ErrorMessage =MSG_ERROR_VALID_PLAYDATE1;
	}
	if (ErrorMessage) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrorMessage 
													   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterLongStyle];
		[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtDate"];
		NSDate *endDate = [NSDate dateWithTimeInterval:86400 sinceDate:selectedDate];
		[self.dict_scheduleData setObject:[formatter stringFromDate:endDate] forKey:@"txtEndDate"];
		[formatter setDateFormat:@"HH:mm:ss"];
		[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtStartTime"];
		NSDate *endtime = [NSDate dateWithTimeInterval:86400 sinceDate:selectedDate];
		[self.dict_scheduleData setObject:[formatter stringFromDate:endtime] forKey:@"txtEndTime"];
		[formatter release];
		
		[self.theTableView reloadData];
	}
}
- (void) showPickerFor :(NSString*) type {
	
	[self.view endEditing:YES];
	[[DELEGATE vi_sideView] setUserInteractionEnabled:NO];
	
	UIDatePicker *pickerView = nil;
	UIView *objView = nil;
//	UINavigationBar *bar = nil;
	if (![[DELEGATE window] viewWithTag:121121]) {
		pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 44, 320, 300)];
		pickerView.datePickerMode = UIDatePickerModeDateAndTime;
		[pickerView addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
		
		objView = [[UIView alloc] initWithFrame:CGRectMake(0, 480, 320, 480)];
		objView.tag = 121121;
		objView.backgroundColor = [UIColor clearColor];
		[objView addSubview:pickerView];
		[[DELEGATE window] addSubview:objView];
		[objView release];
		[pickerView release];

//		bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//		bar.tintColor = [UIColor blackColor];
//		bar.tag = 1111;
//		bar.alpha = 0.8;
//		[objView addSubview:bar];
//		[bar release];
	}else {
		objView = [[DELEGATE window] viewWithTag:121121];
		pickerView = (UIDatePicker *)[objView viewWithTag:111];
		if (!pickerView) {
			pickerView = (UIDatePicker *)[objView viewWithTag:112];			
		}
//		bar = (UINavigationBar *)[objView viewWithTag:1111];
	}

	if ([type isEqualToString:@"startDate"]) {
		pickerView.tag = 111;
	}else if ([type isEqualToString:@"endDate"]) {
		pickerView.tag = 112;
	}
	
//	UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@""];
	if ([type isEqualToString:@"startDate"]) {
		
		if ([self.dict_scheduleData objectForKey:@"txtDate"] && [self.dict_scheduleData objectForKey:@"txtStartTime"]) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			NSDate *dt1 = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtDate"]];
			
			[formatter setDateFormat:@"dd-MM-yyyy"];
			NSString *str = [formatter stringFromDate:dt1];
			
			[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
			NSString *str_date = [NSString stringWithFormat:@"%@ %@",str,[self.dict_scheduleData objectForKey:@"txtStartTime"]];
			NSDate *dt = [formatter dateFromString:str_date];
			pickerView.date = dt;
			[formatter release];
		}
		
//		UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
//																 style:UIBarButtonItemStyleDone 
//																target:self 
//																action:@selector(saveDate:)];
//		item.rightBarButtonItem = done;
	}else {
		
		if ([self.dict_scheduleData objectForKey:@"txtEndDate"] && [self.dict_scheduleData objectForKey:@"txtEndTime"]) {
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			NSDate *dt1 = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtEndDate"]];
			
			[formatter setDateFormat:@"dd-MM-yyyy"];
			NSString *str = [formatter stringFromDate:dt1];
			
			[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
			NSString *str_date = [NSString stringWithFormat:@"%@ %@",str,[self.dict_scheduleData objectForKey:@"txtEndTime"]];
			NSDate *dt = [formatter dateFromString:str_date];
			pickerView.date = dt;
			[formatter release];
		}else if([self.dict_scheduleData objectForKey:@"txtDate"] && [self.dict_scheduleData objectForKey:@"txtStartTime"]) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateStyle:NSDateFormatterLongStyle];
			NSDate *dt1 = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtDate"]];
			
			[formatter setDateFormat:@"dd-MM-yyyy"];
			NSString *str = [formatter stringFromDate:dt1];
			
			[formatter setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
			NSString *str_date = [NSString stringWithFormat:@"%@ %@",str,[self.dict_scheduleData objectForKey:@"txtStartTime"]];
			NSDate *dt = [formatter dateFromString:str_date];
			pickerView.date = dt;
			[formatter release];
		}
		
//		UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
//																 style:UIBarButtonItemStyleDone 
//																target:self 
//																action:@selector(saveTime:)];
//		item.rightBarButtonItem = done;
	}
	
//	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
//															   style:UIBarButtonItemStyleDone 
//															  target:self 
//															  action:@selector(cancelPicker:)];
//	item.leftBarButtonItem = cancel;
//	
//	bar.items = [NSArray arrayWithObject:item];
//	[item release];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.5];
	[objView setFrame:CGRectMake( 0, 221, 320, 480)];
	[UIView commitAnimations];
}


- (void) saveTime :(id) sender {
	
	
	UIView *DateView = [[DELEGATE window] viewWithTag:121121];
	UIDatePicker *DatePick = (UIDatePicker*)[DateView viewWithTag:111];
	NSDate *selectedDate = DatePick.date;
	NSTimeInterval interval = [selectedDate timeIntervalSinceNow];
	
	NSString *ErrorMessage = nil;
	if (interval < 0) {
		ErrorMessage =MSG_ERROR_VALID_PLAYDATE1;
	}
	if (ErrorMessage) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrorMessage 
													   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterLongStyle];
		[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtEndDate"];
		[formatter setDateFormat:@"HH:mm:ss"];
		[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtEndTime"];
		[formatter release];
		
		[self cancelPicker:nil];
		[self.theTableView reloadData];
	}
	
	
}

- (void)saveDate :(id) sender {
	
	UIView *DateView = [[DELEGATE window] viewWithTag:121121];
	UIDatePicker *DatePick = (UIDatePicker*)[DateView viewWithTag:111];
	NSDate *selectedDate = DatePick.date;
	NSTimeInterval interval = [selectedDate timeIntervalSinceNow];
	
	NSString *ErrorMessage = nil;
	if (interval < 0) {
		ErrorMessage =MSG_ERROR_VALID_PLAYDATE1;
	}
	if (ErrorMessage) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:ErrorMessage 
													   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else {
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterLongStyle];
		[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtDate"];
		[formatter setDateFormat:@"HH:mm:ss"];
		[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtStartTime"];
		[formatter release];
		
		[self cancelPicker:nil];
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
    [super dealloc];
}


@end
