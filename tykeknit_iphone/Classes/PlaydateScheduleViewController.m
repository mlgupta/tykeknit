//
//  PlaydateScheduleViewController.m
//  TykeKnit
//
//  Created by Ver on 24/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define PHOTO_INDENT 74.0

#import "JSON.h"
#import "CustomTableViewCell.h"
#import "PlaydateScheduleViewController.h"
#import "PlaydateScheduleKidsViewController.h"
#import "PlaydateScheduleDateTimeViewController.h"
#import "KidsListDetailViewController.h"
#import "Global.h"
#import "Messages.h"

@implementation PlaydateScheduleViewController

@synthesize theTableView,dict_scheduleData, arr_invities,MessageView;
@synthesize dict_kidData,arr_kidData,selectedBuddy;

- (void) viewWillAppear:(BOOL)animated {
	
	if ([[[DELEGATE window] subviews] containsObject:[DELEGATE nav_wannaHangBar].view]) {
		[[DELEGATE nav_wannaHangBar].view removeFromSuperview];
	}
	
	
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_playDate_send aboveSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_playDateSearch belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_wannaHang belowSubview:[DELEGATE vi_sideView].img_back];
	[self.view endEditing:YES];
	[self.theTableView reloadData];
	[super viewWillAppear:animated];
}

- (void) doneClicked : (id) sender {
	
	[self.view endEditing:YES];
	NSString *str_error;
	int flag = 0;
	if (![[self.dict_scheduleData objectForKey:@"txtName"] length]) {
		str_error = MSG_ERROR_VALID_NAME3;
		flag = 1;
	}
	else if (![[self.dict_scheduleData objectForKey:@"txtLocation"] length]) {
		str_error = MSG_ERROR_VALID_LOCATION2;
		flag = 1;
	}
	else if (![[self.dict_scheduleData objectForKey:@"txtDate"] length]) {
		
		str_error = MSG_ERROR_VALID_DATE;
		flag = 1;
	}else if (![[self.dict_scheduleData objectForKey:@"organiserKids"] count]) {
		str_error = @"You have not selected any tyke";
		flag = 1;
	}else if (![[self.dict_scheduleData objectForKey:@"txtStartTime"] length]) {
		str_error = @"Please Specify Start Time";
		flag = 1;
	}else if (![[self.dict_scheduleData objectForKey:@"txtEndTime"] length]) {
		str_error = @"Please Specify End Time";
		flag = 1;
	}else if (![[self.dict_scheduleData objectForKey:@"txtEndDate"] length]) {
		str_error = @"Please Specify End Date";
		flag = 1;
	}else if (![[self.dict_scheduleData objectForKey:@"txtDate"] length]) {
		str_error = MSG_ERROR_VALID_DATE;
		flag = 1;
	}else if (![[self.dict_scheduleData objectForKey:@"buddies"] count]) {
		str_error = @"Please select buddy";
		flag =1;
	}else if ([[self.dict_scheduleData objectForKey:@"buddies"] count]) {
		for (NSDictionary *dict in [self.dict_scheduleData objectForKey:@"buddies"]) {
			if ([[dict objectForKey:@"selected"] intValue]) {
				flag =0;
				break;
			}else {
				str_error = @"Please select buddy";
				flag =1;
			}
		}
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
					str_error = @"Please enter suitable start and end time";
					flag = 1;
				}
				[formatter release];
			}
		}
		if (diffrence > 0) {
			str_error = @"Please enter suitable start and end date";
			flag = 1;
		}
		[formatter release];
	}
	
	/*
	if ([[self.dict_scheduleData objectForKey:@"txtStartTime"] length] && [[self.dict_scheduleData objectForKey:@"txtEndTime"] length]) {
		NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
		[formatter setDateFormat:@"hh:mm:ss"];
		NSDate *startTime = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtStartTime"]];
		NSDate *endTime = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtEndTime"]];
		NSTimeInterval diffrence = [startTime timeIntervalSinceDate:endTime];
		if (diffrence > 0) {
			str_error = @"Please enter suitable start and end time";
			flag = 1;
		}
		[formatter release];
	}
	*/
	
	if (flag) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:str_error 
													   delegate:self cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	if (!flag) {
		NSMutableDictionary *dictToSendOrganiserCids = [[NSMutableDictionary alloc]init];
		NSMutableArray *arr_OrganiserCids = [[NSMutableArray alloc]init];
		
		for (NSDictionary *dict in [self.dict_scheduleData objectForKey:@"organiserKids"]) {
			
			NSMutableDictionary *dict_data =  [[NSMutableDictionary alloc]init];
			[dict_data setObject:[dict objectForKey:@"ChildTblPk"] forKey:@"cid"];
			[arr_OrganiserCids addObject:dict_data];
			[dict_data release];
		}
		
		[dictToSendOrganiserCids setObject:arr_OrganiserCids forKey:@"OrganiserCids"];
		[arr_OrganiserCids release];
		NSString *organiserCids = [dictToSendOrganiserCids JSONRepresentation];
		[dictToSendOrganiserCids release];
		
		NSMutableDictionary *dictToSendBuddies = [[[NSMutableDictionary alloc]init] autorelease];
		NSMutableArray *arr_buddies = [[NSMutableArray alloc]init];
		for (NSDictionary *dictParents in [self.dict_scheduleData objectForKey:@"buddies"]) {
			if ([[dictParents objectForKey:@"selected"] intValue]) {
				
				NSMutableDictionary *dict_data =  [[NSMutableDictionary alloc] init];
				NSMutableArray *arr_tykes = [[NSMutableArray alloc]init];
				for (NSDictionary *dictTyke in [dictParents objectForKey:@"Tykes"]) {
					NSMutableDictionary *dict_data2 = [[NSMutableDictionary alloc]init];
					
					if ([[dictTyke objectForKey:@"selected"] intValue]) {
						[dict_data2 setObject:[dictTyke objectForKey:@"cid"] forKey:@"cid"];
						[arr_tykes addObject:dict_data2];
					}
					[dict_data2 release];
				}
				
				if ([arr_tykes count]) {
					
					[dict_data setObject:[dictParents objectForKey:@"ParentUserTblPk"] forKey:@"Parent"];
					[dict_data setObject:arr_tykes forKey:@"Tykes"];
				}
				
				[arr_tykes release];
				[arr_buddies addObject:dict_data];
				[dict_data release];
			}
		}
		
		[dictToSendBuddies setObject:arr_buddies forKey:@"Invitees"];
		[arr_buddies release];
		NSString *buddies = [dictToSendBuddies JSONRepresentation];
		
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateStyle:NSDateFormatterLongStyle];
		NSString *str_date = [self.dict_scheduleData objectForKey:@"txtDate"];
		NSString *str_endDate =  [self.dict_scheduleData objectForKey:@"txtEndDate"];
		
		NSDate *dtSche = [formatter dateFromString:str_date];
		NSDate *endDate = [formatter dateFromString:str_endDate];
		[formatter setDateFormat:@"YYYY-MM-dd"];
		if ([self.dict_scheduleData objectForKey:@"txtDate"]) {
			str_date = [formatter stringFromDate:dtSche];
		}
		if ([self.dict_scheduleData objectForKey:@"txtEndDate"]) {
			str_endDate = [formatter stringFromDate:endDate];
		}
		
		[formatter release];
		
		[api_tyke playDateRequest:organiserCids 
					 playDateName:[NSString stringWithFormat:@"%@",[self.dict_scheduleData objectForKey:@"txtName"]]
						 Location:[NSString stringWithFormat:@"%@",[self.dict_scheduleData objectForKey:@"txtLocation"]]
							 date:formattedNilValue(str_date)
						startTime:formattedNilValue([self.dict_scheduleData objectForKey:@"txtStartTime"])
						  endTime:formattedNilValue([self.dict_scheduleData objectForKey:@"txtEndTime"])
						  message:formattedNilValue([self.dict_scheduleData objectForKey:@"txtMessage"]) 
					  txtInvitees:buddies
					   txtEndDate:formattedNilValue(str_endDate)
		 ];
		[DELEGATE addLoadingView:self.view];
	}
}

- (void) btn_locationClicked : (id) sender {
	
	[[DELEGATE vi_sideView] setHidden:YES];
	
	ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
	[self presentModalViewController:picker animated:YES];
	[picker release];
}

- (void)viewDidLoad {
	
	UIButton *btn_back = [DELEGATE getDefaultBarButtonWithTitle:@"Cancel"];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Submit"];
	[btn_done addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_done] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Plan"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];
	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate = self;
	
	if (!self.dict_scheduleData) {
		self.dict_scheduleData = [[NSMutableDictionary alloc]init];
	}
	if (![self.arr_kidData count]) {
			self.arr_kidData = [DELEGATE arr_kidsList];
			if (![self.arr_kidData count]) {
				[DELEGATE addLoadingView:self.vi_main];
				[api_tyke getKidList];
			}
	}
	
	[super viewDidLoad];
}

-(void) backPressed:(id)sender{
		[self.dict_scheduleData removeAllObjects];
		for (UIViewController *vi_cont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
}

#pragma mark -
#pragma mark TableViewDelegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	int RET = 6;
	return RET;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 2) {
		return 50;
	}
	
	return 40;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	int RET = 0;
	if (section==0 || section==1 || section ==2 || section==5) 
		RET = 1;
	
	if (section==4) {
		RET = 1;
	}
	else if (section==3) { 
		RET = [self.arr_kidData count];
		if (!RET) {
			RET = 1;
		}
	}
	
	return RET;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	int section = [indexPath section];
	if (section==0) {
		NSString *CellIdentifier = @"title";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.backgroundColor = [UIColor colorWithRed:0.9290 green:0.9490 blue:0.9610 alpha:1.0];
			
			UITextField *txt_Cell = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 240, 44.0)];
			txt_Cell.backgroundColor = [UIColor clearColor];
			txt_Cell.placeholder = @"Title";
			txt_Cell.tag = 1;
			txt_Cell.autocorrectionType = UITextAutocorrectionTypeNo;
			txt_Cell.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			txt_Cell.font = [UIFont fontWithName:@"helvetica Neue" size:15];
			[txt_Cell addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			txt_Cell.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			[txt_Cell addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			[txt_Cell setReturnKeyType:UIReturnKeyNext];
			[cell.contentView addSubview:txt_Cell];
			[txt_Cell release];
		}
		
		UITextField *txt_Cell = (UITextField *)[cell viewWithTag:102];
		if ([self.dict_scheduleData objectForKey:@"txtPlaydateName"]) {
			txt_Cell.text = [self.dict_scheduleData objectForKey:@"txtPlaydateName"];
		}else {
			txt_Cell.text = @"";
		}

		cell.tag = indexPath.section;
		return cell;
	}else if(indexPath.section ==1){
		NSString *CellIdentifier = @"location";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.backgroundColor = [UIColor colorWithRed:0.9290 green:0.9490 blue:0.9610 alpha:1.0];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			
			UITextField *txt_location = [[UITextField alloc]initWithFrame:CGRectMake(10, 9, 200, 20)];
			txt_location.placeholder = @"Enter Location";
			[txt_location addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			txt_location.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			[txt_location addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			txt_location.autocorrectionType = UITextAutocorrectionTypeNo;
			txt_location.tag = 11;
			txt_location.font = [UIFont fontWithName:@"helvetica Neue" size:15];
			txt_location.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			txt_location.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:txt_location];
			[txt_location release];
			
			UIButton *btn_location = [UIButton buttonWithType:UIButtonTypeCustom]; 
			[btn_location setFrame:CGRectMake(220, 8, 35, 22)];
			[btn_location addTarget:self action:@selector(btn_locationClicked:) forControlEvents:UIControlEventTouchUpInside];
			btn_location.tag = 12;
			[btn_location setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_location.png")] forState:UIControlStateNormal];
			btn_location.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:btn_location];
		}
		
		UITextField *txt_location = (UITextField *)[cell viewWithTag:11];
		if ([self.dict_scheduleData objectForKey:@"txtLocation"]) {
			txt_location.text = [self.dict_scheduleData objectForKey:@"txtLocation"];
		}else {
			txt_location.text =@"";
		}

		
		cell.tag = indexPath.section;
		
		return cell;
	}else if (indexPath.section==2) {
		NSString *CellIdentifier = @"time";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.backgroundColor = [UIColor colorWithRed:0.9290 green:0.9490 blue:0.9610 alpha:1.0];
			
			UILabel *lbl_start1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 6, 75, 18)];
			lbl_start1.tag = 21;
			lbl_start1.backgroundColor = [UIColor clearColor];
			lbl_start1.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			lbl_start1.font = [UIFont boldSystemFontOfSize:14];
			lbl_start1.text = @"Starts";
			lbl_start1.layer.shadowColor = [UIColor whiteColor].CGColor;
			lbl_start1.layer.shadowOffset = CGSizeMake(0, 2);
			lbl_start1.layer.shadowRadius = 2.0;
			lbl_start1.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			[cell.contentView addSubview:lbl_start1];
			[lbl_start1 release];
			
			UILabel *lbl_end = [[UILabel alloc]initWithFrame:CGRectMake(10, 26, 75, 18)];
			lbl_end.tag = 22;
			lbl_end.text = @"Ends";
			lbl_end.backgroundColor = [UIColor clearColor];
			lbl_end.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			lbl_end.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			lbl_end.font = [UIFont boldSystemFontOfSize:14];
			[cell.contentView addSubview:lbl_end];
			[lbl_end release];
			
			UILabel *lbl_start2 = [[UILabel alloc]initWithFrame:CGRectMake(105, 7, 125, 15)];
			lbl_start2.tag = 23;
			lbl_start2.textAlignment = UITextAlignmentRight;
			lbl_start2.font = [UIFont fontWithName:@"helvetica Neue" size:13];
			lbl_start2.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			[lbl_start2 setBackgroundColor:[UIColor clearColor]];
			[cell.contentView addSubview:lbl_start2];
			[lbl_start2 release];
			
			UILabel *lbl_end2 = [[UILabel alloc]initWithFrame:CGRectMake(105, 26, 125, 15)];
			lbl_end2.tag = 24;
			lbl_end2.textAlignment = UITextAlignmentRight;
			lbl_end2.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			lbl_end2.font = [UIFont fontWithName:@"helvetica Neue" size:13];
			[lbl_end2 setBackgroundColor:[UIColor clearColor]];
			[cell.contentView addSubview:lbl_end2];
			[lbl_end2 release];
			
			UIButton *btn_startTime = [UIButton buttonWithType:UIButtonTypeCustom];
			btn_startTime.frame = CGRectMake(125, 3, 125, 23);
			btn_startTime.tag = 25;
			btn_startTime.backgroundColor = [UIColor clearColor];
			[btn_startTime addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
			
			UIButton *btn_endTime = [UIButton buttonWithType:UIButtonTypeCustom];
			btn_endTime.tag = 26;
			btn_endTime.frame = CGRectMake(125, 27, 125, 20);
			btn_endTime.backgroundColor = [UIColor clearColor];
			[btn_endTime addTarget:self action:@selector(selectTime:) forControlEvents:UIControlEventTouchUpInside];
		}
		
		UILabel *lbl_start2 = (UILabel *)[cell viewWithTag:23];
		UILabel *lbl_end2 = (UILabel *)[cell viewWithTag:24];
		
		if ([self.dict_scheduleData objectForKey:@"txtDate"] && [self.dict_scheduleData objectForKey:@"txtStartTime"]) {
			NSString *str_date = [self.dict_scheduleData objectForKey:@"txtDate"];
			NSArray *arr = [str_date componentsSeparatedByString:@","];
			NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
			[formatter setDateFormat:@"HH:mm:ss"];
			NSDate *dt = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtStartTime"]];
			[formatter setDateFormat:@"hh:mm a"];
			NSString *startTime = [formatter stringFromDate:dt];
			[formatter release];
			
			lbl_start2.text = [NSString stringWithFormat:@"%@ %@",[arr objectAtIndex:0],startTime];
		}else {
			lbl_start2.text = @"";
		}

		if ([self.dict_scheduleData objectForKey:@"txtEndTime"] && [self.dict_scheduleData objectForKey:@"txtEndDate"]) {
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			NSString *str_date = [self.dict_scheduleData objectForKey:@"txtEndDate"];
			NSArray *arr = [str_date componentsSeparatedByString:@","];
			[formatter setDateFormat:@"HH:mm:ss"];
			NSDate *dt = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtEndTime"]];
			[formatter setDateFormat:@"hh:mm a"];
			NSString *startTime = [formatter stringFromDate:dt];
			lbl_end2.text = [formatter stringFromDate:dt];
			[formatter release]; 
			
			lbl_end2.text = [NSString stringWithFormat:@"%@ %@",[arr objectAtIndex:0],startTime];
		}else {
			lbl_end2.text = @"";
		}

		
		cell.tag = indexPath.section;
		return cell;
	}else if (indexPath.section ==3) {
		NSString *CellIdentifier = @"Tykes";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.backgroundColor = [UIColor colorWithRed:0.9290 green:0.9490 blue:0.9610 alpha:1.0];
			
			UIButton *btn_selectChild = [UIButton buttonWithType:UIButtonTypeCustom];
			btn_selectChild.tag = 33;
			btn_selectChild.selected = NO;
			[btn_selectChild setFrame:CGRectMake(10, 3, 31, 31)];
			[btn_selectChild setBackgroundColor:[UIColor clearColor]];
			[btn_selectChild addTarget:self action:@selector(selectChild:) forControlEvents:UIControlEventTouchUpInside];
			[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];
			[cell.contentView addSubview:btn_selectChild];
			
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 100, 20)];
			lblFirstName.tag = 31; 
			[lblFirstName setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font =[UIFont fontWithName:@"helvetica Neue" size:14];
			lblFirstName.font = [UIFont boldSystemFontOfSize:14];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
			
			UILabel *lbl_childAge = [[UILabel alloc]initWithFrame:CGRectMake(120, 12, 100, 20)];
			[lbl_childAge setTag:32];
			[lbl_childAge setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			[lbl_childAge setBackgroundColor:[UIColor clearColor]];
			lbl_childAge.font = [UIFont fontWithName:@"helvetica Neue" size:13];
			lbl_childAge.font = [UIFont boldSystemFontOfSize:13];
			[cell.contentView addSubview:lbl_childAge];
			[lbl_childAge release];
		}
		
		UILabel *lblFirstName = (UILabel *)[cell viewWithTag:31];
		UILabel *lbl_childAge = (UILabel *)[cell viewWithTag:32];
		UIButton *btn_selectChild = (UIButton *)[cell viewWithTag:33];
		
		if ([self.arr_kidData count]) {
			
			btn_selectChild.hidden = NO;
			lblFirstName.frame = CGRectMake(20, 14, 100, 20);
			
			NSDictionary *dictdata = [self.arr_kidData objectAtIndex:indexPath.row];
			if ([self.dict_scheduleData objectForKey:@"organiserKids"]) {
				for (NSDictionary *dict in [self.dict_scheduleData objectForKey:@"organiserKids"]) {
					if ([[dictdata objectForKey:@"ChildTblPk"] isEqualToString:[dict objectForKey:@"ChildTblPk"]]) {
						[btn_selectChild setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_selectedTyke")] forState:UIControlStateNormal];
						break;
					}else {
						[btn_selectChild setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_deselectTyke")] forState:UIControlStateNormal];
					}
				}
			}else {
				[btn_selectChild setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_deselectTyke")] forState:UIControlStateNormal];
			}

			
			if ([dictdata objectForKey:@"fname"] && [dictdata objectForKey:@"lname"]) {
				lblFirstName.text = [[NSString stringWithFormat:@"%@ %@",[dictdata objectForKey:@"fname"],[dictdata objectForKey:@"lname"]] capitalizedString];
			}else {
				lblFirstName.text = @"";
			}

			
			if ([[dictdata objectForKey:@"WannaHang"] isEqualToString:@"t"]) {
				lblFirstName.textColor = WannaHangColor;
			}else {
				[lblFirstName setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			}

			if ([dictdata objectForKey:@"DOB"]) {
				
				NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
				[formatter setDateFormat:@"yyyy-MM-dd"];
				lbl_childAge.text = [NSString stringWithFormat:@"(%@)",getChildAgeFromDate([formatter dateFromString:[dictdata objectForKey:@"DOB"]])];
				[formatter release];
			}else {
				lbl_childAge.text = @"";
			}

			if ([[dictdata objectForKey:@"gender"] isEqualToString:@"M"]) {
				lbl_childAge.textColor = BoyBlueColor;
			}else {
				lbl_childAge.textColor = GirlPinkColor;
			}
			
			CGSize aSize = [lblFirstName.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(180, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
			lblFirstName.frame = CGRectMake(50, 10, aSize.width, aSize.height);
			aSize = [lbl_childAge.text sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:CGSizeMake(150, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
			lbl_childAge.frame = CGRectMake(lblFirstName.frame.origin.x+lblFirstName.frame.size.width+3, 10, aSize.width, aSize.height);
		}
		else {
			
			lblFirstName.frame = CGRectMake(20, 10, 200, 20);
			btn_selectChild.hidden = YES;
			lbl_childAge.text = @"";
			lblFirstName.text = @"You don't have any tykes";
		}
		
		cell.tag = indexPath.row;
		return cell;
	}
	else if (indexPath.section==4) {
		NSString *CellIdentifier = @"Buddies";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.backgroundColor = [UIColor colorWithRed:0.9290 green:0.9490 blue:0.9610 alpha:1.0];
			
			UILabel *lbl_buddies = [[UILabel alloc]initWithFrame:CGRectMake(10, 9, 175, 20)];
			[lbl_buddies setBackgroundColor:[UIColor clearColor]];
			[lbl_buddies setFont:[UIFont boldSystemFontOfSize:13]];
			[lbl_buddies setTag:41];
			lbl_buddies.textColor = [UIColor darkGrayColor];
			lbl_buddies.text = @"Invite Buddies";
			[cell.contentView addSubview:lbl_buddies];
			[lbl_buddies release];
			
			UILabel *lbl_buddyAge = [[UILabel alloc]initWithFrame:CGRectMake(120, 14, 100, 20)];
			[lbl_buddyAge setTag:42];
			[lbl_buddyAge setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			[lbl_buddyAge setBackgroundColor:[UIColor clearColor]];
			lbl_buddyAge.font = [UIFont fontWithName:@"helvetica Neue" size:13];
			lbl_buddyAge.font = [UIFont boldSystemFontOfSize:13];
			[cell.contentView addSubview:lbl_buddyAge];
			[lbl_buddyAge release];
		}
		
		UILabel *lbl_buddies = (UILabel *)[cell viewWithTag:41];
		UILabel *lbl_buddyAge = (UILabel *)[cell viewWithTag:42];
		
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		lbl_buddies.textColor = [UIColor darkGrayColor];
		lbl_buddies.text = @"Invite Buddies";
		[lbl_buddies setFrame:CGRectMake(10, 9, 175, 20)];
		[lbl_buddyAge setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
		lbl_buddyAge.text = @"";
		
		cell.tag = indexPath.section;
		return cell;
	}else if(indexPath.section ==5) {
		NSString *CellIdentifier = @"Message";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.backgroundColor = [UIColor colorWithRed:0.9290 green:0.9490 blue:0.9610 alpha:1.0];
			
			UITextField *txt_message = [[UITextField alloc]initWithFrame:CGRectMake(10, 10, 175, 20)];
			txt_message.userInteractionEnabled = NO;
			txt_message.autocorrectionType = UITextAutocorrectionTypeNo;
			txt_message.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			txt_message.textColor =[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			[txt_message setBackgroundColor:[UIColor clearColor]];
			txt_message.font = [UIFont fontWithName:@"helvetica Neue" size:15];
			[txt_message addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			txt_message.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			[txt_message addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			[txt_message setPlaceholder:@"Message (Optional)"];
			[txt_message setTag:51];
			[cell.contentView addSubview:txt_message];
			[txt_message release];
		}
		
		return cell;
	}
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *view_ForHeader = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 150, 20)];
	UILabel *lbl_header = [[UILabel alloc]initWithFrame:CGRectMake(20, 3, 100, 15)];
	[lbl_header setFont:[UIFont boldSystemFontOfSize:14]];
	[lbl_header setTextColor:[UIColor darkGrayColor]];
	[lbl_header setTextColor:SectionHeaderColor];
	lbl_header.shadowColor = [UIColor whiteColor];
	lbl_header.shadowOffset = CGSizeMake(0, 1);
	[lbl_header setBackgroundColor:[UIColor clearColor]];
	if (section==1) {
//		[lbl_header setText:@"Location"];
	}else if (section==3) {
		[lbl_header setFrame:CGRectMake(20, 10, 100, 15)];
		[lbl_header setText:@"Tykes"];
	}
	[view_ForHeader addSubview:lbl_header];
	[lbl_header release];
	
	return [view_ForHeader autorelease];	
}


- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	float RET=0.0;
	if (section==0 || section==4 || section==5 || section==2) {
		RET =10.0;
	}else if (section==3) {
		RET =30.0;
	}
	
	return RET;
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (indexPath.section == 1) {   
		return YES;
    } else {
		return NO;
    }
	
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	if (indexPath.section==1) {
		return UITableViewCellEditingStyleDelete;
	}
	return UITableViewCellEditingStyleInsert;
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		if (indexPath.section==1 && indexPath.row==0) {
			if ([[self.dict_scheduleData objectForKey:@"additionalInvitees"] count]==1) {
				[[self.dict_scheduleData objectForKey:@"additionalInvitees"] removeObjectAtIndex:indexPath.row];
				[self.theTableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationRight];
			}else {
				[[self.dict_scheduleData objectForKey:@"additionalInvitees"] removeObjectAtIndex:indexPath.row];
				[self.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
			}
		}else {
			[[self.dict_scheduleData objectForKey:@"additionalInvitees"] removeObjectAtIndex:indexPath.row];
			[self.theTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
		}
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.view endEditing:YES];
	if (indexPath.section == 3) {
		UITableViewCell *cell = [self.theTableView cellForRowAtIndexPath:indexPath];
		UIButton *btn = (UIButton *)[cell.contentView viewWithTag:33];
		[self selectChild:btn];
	}
	
	if (indexPath.section==2) {
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		
		PlaydateScheduleDateTimeViewController *dateTime = [[PlaydateScheduleDateTimeViewController alloc]initWithNibName:@"PlaydateScheduleDateTimeViewController" bundle:nil];
		dateTime.prevContImage = currentImage;
		dateTime.dict_scheduleData = self.dict_scheduleData;
		[self.navigationController pushViewController:dateTime animated:NO];
		[dateTime release];
	}
	if (indexPath.section==4) {
		
		if ([self.arr_kidData count]){
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			
			PlaydateScheduleKidsViewController *playdateScheduleKidsViewController = [[PlaydateScheduleKidsViewController alloc]initWithNibName:@"PlaydateScheduleKidsViewController" bundle:nil];
			playdateScheduleKidsViewController.prevContImage = currentImage;
			playdateScheduleKidsViewController.selectedBuddy = self.selectedBuddy;
			playdateScheduleKidsViewController.child_id = [[self.arr_kidData objectAtIndex:0] objectForKey:@"ChildTblPk"];
			playdateScheduleKidsViewController.dict_scheduleData = self.dict_scheduleData;
			[self.navigationController pushViewController:playdateScheduleKidsViewController animated:NO];
			[playdateScheduleKidsViewController release];
		}else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
															message:@"You don't have any tykes." 
														   delegate:nil 
												  cancelButtonTitle:@"Ok" 
												  otherButtonTitles:nil];
			[alert show];
			[alert release];
		}
	}
	if (indexPath.section == 5) {
		[self addMessageView];
	}
	if (indexPath.section == 1) {
		
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) cancelPlayDate : (id) sender {
	
	[self.dict_scheduleData removeAllObjects];
	[self popToViewController:nil];
}

- (void) sendPlayDate : (id) sender {
	
	NSString *str_error;
	int flag = 0;
	if (![[self.dict_scheduleData objectForKey:@"txtName"] length]) {
		str_error = MSG_ERROR_VALID_NAME3;
		flag = 1;
	}
	else if (![[self.dict_scheduleData objectForKey:@"txtLocation"] length]) {
		str_error = MSG_ERROR_VALID_LOCATION2;
		flag = 1;
	}
	else if (![[self.dict_scheduleData objectForKey:@"txtDate"] length]) {
		str_error = MSG_ERROR_VALID_DATE;
		flag = 1;
	}
	else if (![[self.dict_scheduleData objectForKey:@"txtOrganiserName"] length]) {
		str_error = MSG_ERROR_VALID_PLAYDATE3;
		flag = 1;
	}
	else if (![[self.dict_scheduleData objectForKey:@"txtTime"] length]) {
		str_error = MSG_ERROR_VALID_TIME;
		flag = 1;
	}else if (![[self.dict_scheduleData objectForKey:@"additionalInvitees"] count]) {
		str_error = @"You have not selected any invitee";
		flag = 1;
	}
	
	if (flag) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:str_error 
													   delegate:self cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else {
		[self addMessageView];		
	}
}


- (void) selectChild : (id) sender {
	
	UIButton *btn_selectChild = (UIButton *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[btn_selectChild superview] superview];
	
	
	if (btn_selectChild.selected) {
		NSMutableDictionary *dict = [self.arr_kidData objectAtIndex:cell.tag];
		for (int i =0 ;i < [[self.dict_scheduleData objectForKey:@"organiserKids"] count];i++) {
			if ([[dict objectForKey:@"ChildTblPk"] isEqualToString:[[[self.dict_scheduleData objectForKey:@"organiserKids"] objectAtIndex:i] objectForKey:@"ChildTblPk"]]) {
				[[self.dict_scheduleData objectForKey:@"organiserKids"] removeObject:dict];
			}
		}
		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_deselectTyke")] forState:UIControlStateNormal];
		btn_selectChild.selected = NO;
	}else {
		NSMutableArray *arr = [self.dict_scheduleData objectForKey:@"organiserKids"];
		if (![arr count]) {
			NSMutableArray *arr_selectedKids = [[NSMutableArray alloc]init];
			NSMutableDictionary *dict = [self.arr_kidData objectAtIndex:cell.tag];
			[arr_selectedKids addObject:dict];
			[self.dict_scheduleData setObject:arr_selectedKids forKey:@"organiserKids"];
			[arr_selectedKids release];
		}else {
			NSMutableDictionary *dict = [self.arr_kidData objectAtIndex:cell.tag];
			[dict setObject:@"YES" forKey:@"selected"];				
			[arr addObject:dict];
		}
		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_selectedTyke")] forState:UIControlStateNormal];
		btn_selectChild.selected = YES;		
	}
}

#pragma mark -
#pragma mark API Response

- (void) getKidsResponse : (NSData*) data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	self.arr_kidData = [[response objectForKey:@"response"] objectForKey:@"kids"];
	[self.theTableView reloadData];
	[DELEGATE setArr_kidsList:self.arr_kidData];
	[DELEGATE removeLoadingView:nil];
}

- (void) playDateRequestResp : (NSData*)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.view];
	[DELEGATE bringSideViewToFront];
	
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Playdate" message:@"Playdate request sent." 
													  delegate:self cancelButtonTitle:@"Ok" 
											 otherButtonTitles:nil];
		[alert setTag:301];
		[alert show];
		[alert release];
		
		[self.dict_scheduleData removeAllObjects];
	}
	
	[theTableView reloadData];
}

- (void) addToList : (id) sender {
	
	if ([[self.dict_scheduleData allKeys] count] < 2) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry!" message:MSG_ERROR_VALID_PLAYDATE2
													   delegate:self cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}else{
		
		[self.navigationController popToRootViewControllerAnimated:YES];
	}
}

- (void) showPickerFor :(NSString*) type {
	
	[self.view endEditing:YES];
	
	UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 265, 320, 300)];
	if ([type isEqualToString:@"date"]) {
		pickerView.datePickerMode = UIDatePickerModeDateAndTime;
	}else {
		pickerView.datePickerMode = UIDatePickerModeTime;
	}
	pickerView.tag = 111;
	
	UIView *objView = [[UIView alloc] initWithFrame:CGRectMake(0, 480, 320, 480)];
	objView.tag = 121121;
	objView.backgroundColor = [UIColor clearColor];
	[objView addSubview:pickerView];
	[pickerView release];
	
	UINavigationBar *bar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 221, 320, 44)];
	bar.tintColor = [UIColor blackColor];
	bar.alpha = 0.8;
	
	UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@""];
	if ([type isEqualToString:@"date"]) {
		
		if ([self.dict_scheduleData objectForKey:@"txtDate"] && [self.dict_scheduleData objectForKey:@"txtStartTime"]) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			
			[formatter setDateStyle:NSDateFormatterMediumStyle];
			NSDate *dt1 = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtDate"]];
			
			[formatter setDateFormat:@"dd-MM-yyyy"];
			NSString *str = [formatter stringFromDate:dt1];
			
			[formatter setDateFormat:@"dd-MM-yyyy hh:mm:ss"];
			NSString *str_date = [NSString stringWithFormat:@"%@ %@",str,[self.dict_scheduleData objectForKey:@"txtStartTime"]];
			NSDate *dt = [formatter dateFromString:str_date];
			pickerView.date = dt;
			[formatter release];
		}
		UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
																 style:UIBarButtonItemStyleDone 
																target:self 
																action:@selector(saveDate:)];
		item.rightBarButtonItem = done;
	}else {
		if ([self.dict_scheduleData objectForKey:@"txtEndTime"]) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"hh:mm:ss"];
			pickerView.date = [formatter dateFromString:[self.dict_scheduleData objectForKey:@"txtEndTime"]];
			[formatter release];
		}
		UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
																 style:UIBarButtonItemStyleDone 
																target:self 
																action:@selector(saveTime:)];
		item.rightBarButtonItem = done;
	}
	
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" 
															   style:UIBarButtonItemStyleDone 
															  target:self 
															  action:@selector(cancelPicker:)];
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

- (void) selectDate:(id) sender {
	
	[self showPickerFor:@"date"];
}

- (void) selectTime : (id) sender {
	
	[self showPickerFor:@"time"];
}


- (void) cancelPicker : (id) sender {
	
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


- (void) saveTime :(id) sender {
	
	UIView *DateView = [[DELEGATE window] viewWithTag:121121];
	UIDatePicker *DatePick = (UIDatePicker*)[DateView viewWithTag:111];
	NSDate *selectedDate = DatePick.date;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"HH:mm:ss"];
	[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtEndTime"];
	[formatter release];
	[self cancelPicker:nil];
	[self.theTableView reloadData];
	
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

		if (isValidString([formatter stringFromDate:selectedDate])) {
			[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtDate"];			
		} else {
			[self.dict_scheduleData setObject:@"" forKey:@"txtDate"];			
		}

		
		[formatter setDateFormat:@"HH:mm:ss"];
		[self.dict_scheduleData setObject:[formatter stringFromDate:selectedDate] forKey:@"txtStartTime"];
		[formatter release];
		
		[self cancelPicker:nil];
		[self.theTableView reloadData];
	}
}

- (void) nextPressed : (id) sender {
	
	UITextField *txt_field = (UITextField*)sender;
	id objCell = [[txt_field superview] superview];
	if (objCell && [objCell isKindOfClass:[UITableViewCell class]]) {
		UITableViewCell *tableCell = (UITableViewCell*)objCell;
		
		UITableViewCell *nextCell;
		int currTag = tableCell.tag;
		switch (currTag) {
			case 0:{
				nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
				if (nextCell) {
					[[nextCell viewWithTag:11] becomeFirstResponder];
				}
			}
				
			break;
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
		if ([reuseIdentifier isEqualToString:@"title"]) {
			[self.dict_scheduleData setObject:DefaultStringValue(value) forKey:@"txtName"];
		}
		if ([reuseIdentifier isEqualToString:@"Message"]) {
			[self.dict_scheduleData setObject:DefaultStringValue(value) forKey:@"txtMessage"];
		}
		if ([reuseIdentifier isEqualToString:@"location"]) {
			[self.dict_scheduleData setObject:DefaultStringValue(value) forKey:@"txtLocation"];
		}
		
	}
	[self.theTableView reloadData];
	[sender resignFirstResponder];
}


#pragma mark -
#pragma mark MessageView Methods
- (void) addMessageView {
	
	self.MessageView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 468)];
	[self.MessageView setBackgroundColor:[UIColor blackColor]];
	
	UITextView  *txt_messageView = [[UITextView alloc]initWithFrame:CGRectMake(25, 35, 270, 165)];
	txt_messageView.layer.borderColor = [UIColor blackColor].CGColor;
	txt_messageView.layer.borderWidth = 2.0;
	txt_messageView.layer.cornerRadius = 5.0;
	txt_messageView.font = [UIFont boldSystemFontOfSize:16];
	txt_messageView.backgroundColor = [UIColor whiteColor];
	[txt_messageView becomeFirstResponder];
	txt_messageView.delegate = self;
	[txt_messageView setKeyboardAppearance:UIKeyboardAppearanceDefault];
	[self.MessageView addSubview:txt_messageView];
	[txt_messageView release];
	if ([self.dict_scheduleData objectForKey:@"txtMessage"]) {
		txt_messageView.text = [self.dict_scheduleData objectForKey:@"txtMessage"];
	}
	UINavigationItem *nav_item = [[UINavigationItem alloc] init];
	nav_item.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Add Message"];
	UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 221, 320, 44)];
//	[navBar setTintColor:[UIColor colorWithRed:0.623 green:0.850 blue:0.996 alpha:1]];
	navBar.tag = 1111;
	
	UIButton *btn1 = [DELEGATE getDefaultBarButtonWithTitle:@"Cancel"];
	[btn1 addTarget:self action:@selector(btnCancelClicked:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *btn_cancel = [[UIBarButtonItem alloc]initWithCustomView:btn1];
	[nav_item setLeftBarButtonItem:btn_cancel];
	[btn_cancel release];

	UIButton *btn2 = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	[btn2 addTarget:self action:@selector(btnDoneClicked:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *btn_done = [[UIBarButtonItem alloc]initWithCustomView:btn2];
	[nav_item setRightBarButtonItem:btn_done];
	[btn_done release];
	
	[navBar pushNavigationItem:nav_item animated:NO];
	[nav_item release];
	[self.MessageView addSubview:navBar];
	[navBar release];
	
	[[DELEGATE window] addSubview:self.MessageView];
	[self.MessageView release];
	
    self.MessageView.frame = CGRectOffset(self.MessageView.frame, 0, 480);
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.33];
    [UIView setAnimationDelegate:self];
    self.MessageView.frame = CGRectOffset(self.MessageView.frame, 0, -480);
    [UIView commitAnimations];
	
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	
	if(range.length > text.length){
		return YES;
	}else if([[textView text] length] + text.length > 200){
		return NO;
	}
	
	return YES;	
}

- (void) btnDoneClicked : (id) sender {
	
	NSString *txtMessage = [[[self.MessageView subviews] objectAtIndex:0] text];
	UITableViewCell *cell =	[self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5]];
	[(UITextField *)[cell.contentView viewWithTag:51] setText:[NSString stringWithFormat:@"Message : %@",txtMessage]];
	
	if ([txtMessage length]) {
		
        [[[self.MessageView subviews] objectAtIndex:0] resignFirstResponder];

		[self.dict_scheduleData setObject:txtMessage forKey:@"txtMessage"];

        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.66];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeMessageView)];
        self.MessageView.frame = CGRectOffset(self.MessageView.frame, 0, 480);
        [UIView commitAnimations];

		[self.MessageView removeFromSuperview];
		
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Playdate Message"
													   message:@"You have not entered any message."
													  delegate:self
											 cancelButtonTitle:@"Ok"
											 otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (void) btnCancelClicked : (id) sender {
	if ([self.dict_scheduleData objectForKey:@"txtMessage"]) {
		[self.dict_scheduleData setObject:@"" forKey:@"txtMessage"];
	}

    [[[self.MessageView subviews] objectAtIndex:0] setText:@""];
	UITableViewCell *cell =	[self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:5]];
	[(UITextField *)[cell.contentView viewWithTag:51] setText:[NSString stringWithFormat:@"Message : "]];

    [[[self.MessageView subviews] objectAtIndex:0] resignFirstResponder];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.66];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeMessageView)];
    self.MessageView.frame = CGRectOffset(self.MessageView.frame, 0, 480);
    [UIView commitAnimations];
    
}

- (void) removeMessageView {
    [self.MessageView removeFromSuperview];
}

#pragma mark -
#pragma mark peoplePickerDelegate Methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker {
	[[DELEGATE vi_sideView] setHidden:NO];
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController: (ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	ABMutableMultiValueRef addressMulti = ABRecordCopyValue(person, kABPersonAddressProperty);
	NSMutableArray *address = [[NSMutableArray alloc] init];
	int i;
	for (i = 0; i < ABMultiValueGetCount(addressMulti); i++) {
		NSString *city = [(NSString*)ABMultiValueCopyValueAtIndex(addressMulti, i) autorelease];
		[address addObject:city];
	}
	if ([address count] > 0) {
		NSMutableDictionary *primaryAddress = [address objectAtIndex:0];
//		NSString *meCity1 = (NSString *)[primaryAddress objectForKey:@"City"];
		NSString *strToShow = [NSString stringWithFormat:@"%@,%@,%@,%@",(NSString *)[primaryAddress objectForKey:@"Street"],(NSString *)[primaryAddress objectForKey:@"City"],(NSString *)[primaryAddress objectForKey:@"State"],(NSString *)[primaryAddress objectForKey:@"Country"]];
		[self.dict_scheduleData setObject:DefaultStringValue(strToShow) forKey:@"txtLocation"];
	}else {
		[self.dict_scheduleData setObject:@"" forKey:@"txtLocation"];
	}
	[self.theTableView reloadData];
	[address release];
	[[DELEGATE vi_sideView] setHidden:NO];
	[self dismissModalViewControllerAnimated:YES];
	
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 300) {
		[self.dict_scheduleData removeAllObjects];
		[self.theTableView reloadData];
	} else if (alertView.tag == 301) {
		for (UIViewController *vi_cont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
	}
		
}


- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [super dealloc];
}

@end
