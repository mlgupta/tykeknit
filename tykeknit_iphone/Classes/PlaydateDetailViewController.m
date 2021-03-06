//
//  PlaydateDetailViewController.m
//  TykeKnit
//
//  Created by Ver on 08/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaydateDetailViewController.h"
#import "MessagesViewController.h"
#import "PastPlaydatesViewController.h"
#import "DashboardViewController.h"
#import "JSON.h"
#import "CustomSegmentView.h"
#import <EventKit/EventKit.h>

@implementation PlaydateDetailViewController
@synthesize theTableView, dict_data,playdate_id,dict_participants,MessageView,arr_messages,RSVPAccepted;

- (void) backPressed:(id) sender {
	[self popViewController];
}


- (void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void) drawMessagesCellView {
	
	if ([self.arr_messages count]) {
		vi_messagesCellView = [[UIView alloc] initWithFrame:CGRectZero];
		vi_messagesCellView.backgroundColor = [UIColor clearColor];
		int yAxics  = 0;//30+30+lbl_playdateMessage.frame.size.height;
		for (int i=0; i < [self.arr_messages count]; i++) {
			
			UILabel *lbl_MessageFrom = [[UILabel alloc]initWithFrame:CGRectMake(10, 30, 100, 20)];
			lbl_MessageFrom.tag = 12;
			[lbl_MessageFrom setTextColor:[UIColor colorWithRed:0.161 green:0.235 blue:0.404 alpha:1]];
			[lbl_MessageFrom setFont:[UIFont boldSystemFontOfSize:13]];
			lbl_MessageFrom.backgroundColor = [UIColor clearColor];
			[vi_messagesCellView addSubview:lbl_MessageFrom];
			[lbl_MessageFrom release];
			
			UILabel *lbl_messageTimestamp = [[UILabel alloc]initWithFrame:CGRectMake(110, 30, 150, 20)];
			lbl_messageTimestamp.tag = 13;
//			lbl_messageTimestamp.text = @"May 22, 2011 3:30 PM";
			[lbl_messageTimestamp setTextColor:[UIColor colorWithRed:0.161 green:0.235 blue:0.404 alpha:1]];
			[lbl_messageTimestamp setFont:[UIFont systemFontOfSize:13]];
			lbl_messageTimestamp.backgroundColor = [UIColor clearColor];
			[vi_messagesCellView addSubview:lbl_messageTimestamp];
			[lbl_messageTimestamp release];
			
			UILabel *lbl_playdateMessage = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 200, 40)];
			lbl_playdateMessage.tag = 14;
			lbl_playdateMessage.numberOfLines = 0;
			lbl_playdateMessage.font =[UIFont systemFontOfSize:15];
			//			lbl_playdateMessage.text = @"Hello all";
			[lbl_playdateMessage setTextColor:[UIColor grayColor]];
			lbl_playdateMessage.backgroundColor = [UIColor clearColor];
			[vi_messagesCellView addSubview:lbl_playdateMessage];
			[lbl_playdateMessage release];
			
			NSDictionary *dict = [self.arr_messages objectAtIndex:i];
			if ([dict objectForKey:@"message"]) {
				lbl_playdateMessage.text = [dict objectForKey:@"message"];
				
				if ([dict objectForKey:@"firstName"] && [dict objectForKey:@"lastName"]) {
					lbl_MessageFrom.text = [[NSString stringWithFormat:@"%@ %@ : ",[dict objectForKey:@"firstName"],[dict objectForKey:@"lastName"]] capitalizedString];
				}
			}
			
			if ([dict objectForKey:@"time"]) {
				NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//				NSArray *arr = [[dict objectForKey:@"time"] componentsSeparatedByString:@"."];
//				NSString *str_time = [arr objectAtIndex:0];
				[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SZ"];
//				NSDate *dt1 = [formatter dateFromString:str_time];
				NSDate *dt1 = [formatter dateFromString:[dict objectForKey:@"time"]];
				[formatter setDateStyle:NSDateFormatterMediumStyle];
				NSString *str_label = [formatter stringFromDate:dt1];
				[formatter setDateFormat:@"h:mm a"];
				NSString *str =	[formatter stringFromDate:dt1];
				lbl_messageTimestamp.text = [NSString stringWithFormat:@"%@ %@",str_label,str];
				[formatter release];
			}
			
			
			CGSize sizeForFirstName = [lbl_MessageFrom.text sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:CGSizeMake(200, FLT_MAX)];
			lbl_MessageFrom.frame = CGRectMake(20, yAxics, sizeForFirstName.width, sizeForFirstName.height);
			
			CGSize sizeForTimestamp = [lbl_messageTimestamp.text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(130, FLT_MAX)];
			lbl_messageTimestamp.frame = CGRectMake(lbl_MessageFrom.frame.origin.x+lbl_MessageFrom.frame.size.width+5, yAxics, sizeForTimestamp.width, lbl_MessageFrom.frame.size.height);
			lbl_messageTimestamp.adjustsFontSizeToFitWidth = YES;
			
			CGSize sizeForMessage = [lbl_playdateMessage.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(240, FLT_MAX)];
			lbl_playdateMessage.frame = CGRectMake(20, yAxics + sizeForFirstName.height, sizeForMessage.width, sizeForMessage.height);
			
			yAxics = lbl_playdateMessage.frame.origin.y + lbl_playdateMessage.frame.size.height + 10;  
		}
		
		if ([self.dict_data objectForKey:@"playdateMessage"]) {
			CGSize size = [[self.dict_data objectForKey:@"playdateMessage"] sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
			vi_messagesCellView.frame = CGRectMake(0, size.height+65, 260, yAxics);
		}else {
			vi_messagesCellView.frame = CGRectMake(0, 55, 260, yAxics);
		}

	}
}

- (void)viewDidLoad {
	
	UIButton *btn = [DELEGATE getBackBarButton];
	[btn addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn] autorelease];
	
//	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
//	[btn_done addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
//	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn_done] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Playdate"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	
	self.arr_messages  =[[NSMutableArray alloc]init];
	self.dict_data = [[NSMutableDictionary alloc]init];
	self.dict_participants = [[NSMutableDictionary alloc]init];
	self.RSVPAccepted = NO;
	if (!api_tyke) {
		api_tyke = [[TykeKnitApi alloc]init];
		api_tyke.delegate = self;
	}
	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke getPlayDateDetails:self.playdate_id];
    [super viewDidLoad];
	
}

#pragma mark -
#pragma mark tableView DELEGATE Methods

- (NSString *)getSectionLabelForSection:(int)section {

	BOOL RSVPPresent = YES;
	if ([[self.dict_data objectForKey:@"organiserUserID"] isEqualToString:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"txtUserTblPk"]]) {
		RSVPPresent = NO;
	}
	
	NSString *str = nil;
	if (section == 0) {
		str = @"InfoCell";
	}else if (section == 1) {
		if (RSVPPresent) {
			str = @"RSVPCell";
		}else {
			str = @"MessageCell";
		}
	}else if (section == 2) {
		if (RSVPPresent) {
			str = @"MessageCell";
		}else {
			if ([[self.dict_participants objectForKey:@"YesAttending"] count]) {
				str = @"YesAttendingCell";
			}else if ([[self.dict_participants objectForKey:@"NoAttending"] count]) {
				str = @"NoAttendingCell";
			}else if ([[self.dict_participants objectForKey:@"MaybeAttending"] count]) {
				str = @"MaybeAttendingCell";
			}
		}
	}else if (section == 3) {
		if (RSVPPresent) {
			if ([[self.dict_participants objectForKey:@"YesAttending"] count]) {
				str = @"YesAttendingCell";
			}else if ([[self.dict_participants objectForKey:@"NoAttending"] count]) {
				str = @"NoAttendingCell";
			}else if ([[self.dict_participants objectForKey:@"MaybeAttending"] count]) {
				str = @"MaybeAttendingCell";
			}
		}else if ([[self.dict_participants objectForKey:@"NoAttending"] count]) {
			str = @"NoAttendingCell";
		}else if ([[self.dict_participants objectForKey:@"MaybeAttending"] count]) {
			str = @"MaybeAttendingCell";
		}
	}else if (section == 4) {
		if (RSVPPresent) {
			if ([[self.dict_participants objectForKey:@"NoAttending"] count]) {
				str = @"NoAttendingCell";
			}else if ([[self.dict_participants objectForKey:@"MaybeAttending"] count]) {
				str = @"MaybeAttendingCell";
			}
		}else if ([[self.dict_participants objectForKey:@"MaybeAttending"] count]) {
			str = @"MaybeAttendingCell";
		}
	}else if (section == 5) {
		str = @"MaybeAttendingCell";
	}
	return str;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {

	int RET = 2;
	if (![[self.dict_data objectForKey:@"organiserUserID"] isEqualToString:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"txtUserTblPk"]]) {
		RET = RET +1;
	}
	if ([[self.dict_participants objectForKey:@"YesAttending"] count]) {
		RET = RET +1;
	}
	if ([[self.dict_participants objectForKey:@"NoAttending"] count]) {
		RET = RET +1;
	}
	if ([[self.dict_participants objectForKey:@"MaybeAttending"] count]) {
		RET = RET +1;
	}
	
	return RET;
//	
//	return 3;
//	
//	if ([self.arr_messages count] || [self.dict_data objectForKey:@"playdateMessage"]) {
//		return 2;
//	}
//	return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

		int RET = 0;
	NSString *strLabel = [self getSectionLabelForSection:section];
	if ([strLabel isEqualToString:@"InfoCell"] || [strLabel isEqualToString:@"RSVPCell"] || [strLabel isEqualToString:@"MessageCell"]) {
		RET = 1;
	}else if ([strLabel isEqualToString:@"YesAttendingCell"]) {
		if ([[self.dict_participants objectForKey:@"YesAttending"] count]) {
			RET = [[self.dict_participants objectForKey:@"YesAttending"] count];
		}
	}else if ([strLabel isEqualToString:@"NoAttendingCell"]) {
		if ([[self.dict_participants objectForKey:@"NoAttending"] count]) {
			RET = [[self.dict_participants objectForKey:@"NoAttending"] count];
		}
	}else if ([strLabel isEqualToString:@"MaybeAttendingCell"]) {
		if ([[self.dict_participants objectForKey:@"MaybeAttending"] count]) {
			RET = [[self.dict_participants objectForKey:@"MaybeAttending"] count];
		}
	}

	return RET;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Enter %s",__PRETTY_FUNCTION__);
	int RET = 0;
	
	NSString *strLabel = [self getSectionLabelForSection:indexPath.section];
	if ([strLabel isEqualToString:@"InfoCell"]) {
		if (self.dict_data) {
			CGSize sizeForName = [[self.dict_data objectForKey:@"playdateName"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14] constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			CGSize sizeForLocation = [[self.dict_data objectForKey:@"Location"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:13] constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			CGSize sizeForDate =  [[self.dict_data objectForKey:@"date"] sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			
			NSString *str_duration = [NSString stringWithFormat:@"From %@ to %@",[self.dict_data objectForKey:@"StartTime"],[self.dict_data objectForKey:@"EndTime"]];
			CGSize sizeForDuration = [str_duration sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			RET = sizeForName.height+sizeForLocation.height+sizeForDate.height+sizeForDuration.height+65;
			
			if ([[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"txtUserTblPk"] isEqualToString:[self.dict_data objectForKey:@"organiserUserID"]]) {
				RET = sizeForName.height+sizeForLocation.height+sizeForDate.height+sizeForDuration.height+80;
			}
		}
	}else if ([strLabel isEqualToString:@"RSVPCell"]) {
		RET = 55;
	}else if ([strLabel isEqualToString:@"MessageCell"]) {
		if ([self.arr_messages count]) {
			[self drawMessagesCellView];
			if ([self.dict_data objectForKey:@"playdateMessage"]) {
				CGSize size = [[self.dict_data objectForKey:@"playdateMessage"] sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
				RET = vi_messagesCellView.frame.size.height+size.height+100;
			}else {
				RET = vi_messagesCellView.frame.size.height+100;
			}
			
		}else {
			if ([self.dict_data objectForKey:@"playdateMessage"]) {
				CGSize size = [[self.dict_data objectForKey:@"playdateMessage"] sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
				RET = size.height+106;
			}else {
				RET = 90;
			}
		}
	}else {
		RET = 44;
	}

//    NSLog(@"Exit %s",__PRETTY_FUNCTION__);
	
	return RET;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	NSString *strLabel = [self getSectionLabelForSection:section];
	if ( [strLabel isEqualToString:@"MessageCell"]) {
		return 10.0;
	}else {
		return 0.0;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	UIView *vi = [[UIView alloc] initWithFrame:CGRectZero];
	NSString *strLabel = [self getSectionLabelForSection:section];
	if ( [strLabel isEqualToString:@"MessageCell"]) {
		vi.frame = CGRectMake(0, 0, 200, 30);
	}
	
	return [vi autorelease];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {

	int RET = 0;
	NSString *strLabel = [self getSectionLabelForSection:section];
	if ([strLabel isEqualToString:@"RSVPCell"] || [strLabel isEqualToString:@"MessageCell"]) {
		RET = 30;
	}else if ([strLabel isEqualToString:@"YesAttendingCell"] || [strLabel isEqualToString:@"NoAttendingCell"] || [strLabel isEqualToString:@"MaybeAttendingCell"]) {
		RET = 37;
	}
	return RET;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	UIImageView *vi = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 284, 37)];
	
	UILabel *lbl_head = [[UILabel alloc] initWithFrame:CGRectMake(23, 10, 280, 20)];
	lbl_head.font = [UIFont boldSystemFontOfSize:15];
	lbl_head.backgroundColor = [UIColor clearColor];
	lbl_head.textColor = [UIColor blackColor];
	lbl_head.shadowColor = [UIColor whiteColor];
	lbl_head.shadowOffset = CGSizeMake( 0, 1);
	[vi addSubview:lbl_head];
	[lbl_head release];
	
	NSString *strLabel = [self getSectionLabelForSection:section];
	if ([strLabel isEqualToString:@"RSVPCell"]) {
		lbl_head.frame = CGRectMake(20, 5, 240, 20);
		lbl_head.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
		vi.backgroundColor = self.theTableView.backgroundColor;
		lbl_head.text = @"RSVP";
	}else if ([strLabel isEqualToString:@"YesAttendingCell"]) {
		[vi setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"headerView_Background")]];
		lbl_head.text = @"Yes";
	}else if([strLabel isEqualToString:@"NoAttendingCell"]){
		[vi setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"headerView_Background")]];
		lbl_head.text = @"No";
	}else if([strLabel isEqualToString:@"MaybeAttendingCell"]){
	[vi setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"headerView_Background")]];
		lbl_head.text = @"Maybe";
	}
	return [vi autorelease];
}
	
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	self.theTableView.backgroundColor = [UIColor colorWithRed:0.875 green:0.906 blue:0.918 alpha:1.0];
	
	NSString *strLabel = [self getSectionLabelForSection:indexPath.section];
	if ([strLabel isEqualToString:@"InfoCell"]) {
		NSString *userInfoCell = @"PlaydateInfoCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.backgroundColor = [UIColor colorWithRed:0.933 green:0.949 blue:0.961 alpha:1.0];
			
			UIView *vi_background = [[UIView alloc]initWithFrame:CGRectZero];
			vi_background.tag = 1001;
			vi_background.layer.borderColor = [UIColor grayColor].CGColor;
			vi_background.layer.cornerRadius = 10.0;
			vi_background.layer.borderWidth = 1.0;
			[cell.contentView addSubview:vi_background];
			[vi_background release];
			
			UILabel *lbl_playdateName = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 200, 20)];
			lbl_playdateName.backgroundColor = [UIColor clearColor];
			lbl_playdateName.tag = 1;
			lbl_playdateName.textColor =[UIColor colorWithRed:0.298 green:0.318 blue:0.396 alpha:1];
//			[lbl_playdateName setFont:[UIFont boldSystemFontOfSize:16]];
			[lbl_playdateName setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]];
            lbl_playdateName.lineBreakMode = UILineBreakModeWordWrap;
            lbl_playdateName.numberOfLines = 0;
			[cell.contentView addSubview:lbl_playdateName];
			[lbl_playdateName release];
			
			UILabel *lbl_playdateLocation = [[UILabel alloc]initWithFrame:CGRectMake(10, 37, 200, 40)];
			lbl_playdateLocation.tag = 2;
			lbl_playdateLocation.backgroundColor = [UIColor clearColor];
			lbl_playdateLocation.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
			//	lbl_playdateLocation.text = @"-509, Megacenter, Pune Solapur Highway, Hadapsar, Pune.";
			lbl_playdateLocation.textColor = [UIColor grayColor];
            lbl_playdateLocation.lineBreakMode = UILineBreakModeWordWrap;
			lbl_playdateLocation.numberOfLines = 0;
			[cell.contentView addSubview:lbl_playdateLocation];
			[lbl_playdateLocation release];
			
			UILabel *lbl_playdateDate = [[UILabel alloc]initWithFrame:CGRectMake(10, 80, 160, 15)];
			lbl_playdateDate.tag = 3;
			lbl_playdateDate.backgroundColor =[UIColor clearColor];
			lbl_playdateDate.font = [UIFont fontWithName:@"helvetica Neue" size:10];
			lbl_playdateDate.textColor = [UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];
			//	lbl_playdateDate.text = @"Friday, April 8,2011";
			[cell.contentView addSubview:lbl_playdateDate];
			[lbl_playdateDate release];
			
			UILabel *lbl_playdateDuration = [[UILabel alloc]initWithFrame:CGRectMake(10, 95, 160, 15)];
			//	[lbl_playdateDuration setText:@"From 1.30 PM to 3.30 PM"];
			lbl_playdateDuration.backgroundColor = [UIColor clearColor];
			lbl_playdateDuration.font = [UIFont fontWithName:@"helvetica Neue" size:10];
			lbl_playdateDuration.textColor = [UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];
			lbl_playdateDuration.tag = 4;
			[cell.contentView addSubview:lbl_playdateDuration];
			[lbl_playdateDuration release];
			
			
			UILabel *organiser = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 160, 15)];
			organiser.text = @"Organizer:";
			organiser.backgroundColor = [UIColor clearColor];
			organiser.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
			organiser.textColor = [UIColor grayColor];
			organiser.tag = 5;
			[cell.contentView addSubview:organiser];
			[organiser release];
			
			UILabel *organiser_name = [[UILabel alloc]initWithFrame:CGRectMake(10, 120, 160, 15)];
			organiser_name.backgroundColor = [UIColor clearColor];
			organiser_name.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
			organiser_name.textColor =  [UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];
			organiser_name.tag = 6;
			[cell.contentView addSubview:organiser_name];
			[organiser_name release];
			
			UIButton *btn_cancelEvent = [UIButton buttonWithType:UIButtonTypeCustom];
			[btn_cancelEvent setFrame:CGRectMake(90, 120, 76, 23)];
			[btn_cancelEvent setTag:7];
			[btn_cancelEvent setHidden:YES];
			btn_cancelEvent.titleLabel.font = [UIFont boldSystemFontOfSize:11];
			[btn_cancelEvent addTarget:self action:@selector(cancelPlayDate:) forControlEvents:UIControlEventTouchUpInside];
			[btn_cancelEvent setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"cancel_event")] forState:UIControlStateNormal];
			//				[btn_cancelEvent setTitle:@"Cancel Event" forState:UIControlStateNormal];
			[cell.contentView addSubview:btn_cancelEvent];
			
		}
		
		UILabel *lbl_playdateName = (UILabel *)[cell.contentView viewWithTag:1];
		UILabel *lbl_playdateLocation = (UILabel *)[cell.contentView viewWithTag:2];
		UILabel *lbl_playdateDate = (UILabel *)[cell.contentView viewWithTag:3];
		UILabel *lbl_playdateDuration = (UILabel *)[cell.contentView viewWithTag:4];
		UILabel *lbl_organizer = (UILabel *)[cell.contentView viewWithTag:5];
		UILabel *lbl_orgaizerName = (UILabel *)[cell.contentView viewWithTag:6];
		UIButton *btn_cancel = (UIButton *)[cell.contentView viewWithTag:7];		
		
		if ([[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"txtUserTblPk"] isEqualToString:[self.dict_data objectForKey:@"organiserUserID"]]) {
			btn_cancel.hidden = NO;
		}
		
		if ([self.dict_data objectForKey:@"playdateName"]) {
			lbl_playdateName.text = [self.dict_data objectForKey:@"playdateName"];
		}
		
		if ([self.dict_data objectForKey:@"Location"]) {
			lbl_playdateLocation.text = [self.dict_data objectForKey:@"Location"];
		}
		
		if ([self.dict_data objectForKey:@"date"] && [self.dict_data objectForKey:@"StartTime"]){
			NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
			[formatter setDateFormat:@"HH:mm"];
			NSDate *time = [formatter dateFromString:[self.dict_data objectForKey:@"StartTime"]];
			[formatter setDateFormat:@"hh:mm a"];
			NSString *startTime = [formatter stringFromDate:time];
			[formatter setDateFormat:@"yyyy-MM-dd"];
			NSDate *dt = [formatter dateFromString:[self.dict_data objectForKey:@"date"]];
			[formatter setDateStyle:NSDateFormatterFullStyle];
			lbl_playdateDate.text = [NSString stringWithFormat:@"From %@ %@",startTime,[formatter stringFromDate:dt]];//[self.dict_data objectForKey:@"date"];
			[formatter release];
		}
		
		if ([self.dict_data objectForKey:@"endDate"] && [self.dict_data objectForKey:@"EndTime"]) {
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
			[formatter setDateFormat:@"HH:mm"];
			NSDate *time = [formatter dateFromString:[self.dict_data objectForKey:@"EndTime"]];
			[formatter setDateFormat:@"hh:mm a"];
			NSString *endTime = [formatter stringFromDate:time];
			[formatter setDateFormat:@"yyyy-MM-dd"];
			NSDate *dt = [formatter dateFromString:[self.dict_data objectForKey:@"endDate"]];
			[formatter setDateStyle:NSDateFormatterFullStyle];
			lbl_playdateDuration.text = [NSString stringWithFormat:@"     To %@ %@",endTime,[formatter stringFromDate:dt]];
			[formatter release];
		}
		
		if ([self.dict_data objectForKey:@"OrganiserFName"] && [self.dict_data objectForKey:@"OrganiserLName"]) {
			lbl_orgaizerName.text = [NSString stringWithFormat:@"%@ %@",[self.dict_data objectForKey:@"OrganiserFName"],[self.dict_data objectForKey:@"OrganiserLName"]];
		}
		
		
		CGSize size = [lbl_playdateName.text sizeWithFont:lbl_playdateName.font constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:lbl_playdateName.lineBreakMode];
		[lbl_playdateName setFrame:CGRectMake(20, 20, size.width, size.height)];
		
		size = [lbl_playdateLocation.text sizeWithFont:lbl_playdateLocation.font constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:lbl_playdateLocation.lineBreakMode];
		[lbl_playdateLocation setFrame:CGRectMake(20, lbl_playdateName.frame.origin.y+lbl_playdateName.frame.size.height, size.width, size.height)];
		
		size = [lbl_playdateDate.text sizeWithFont:lbl_playdateDate.font constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:lbl_playdateDate.lineBreakMode];
		[lbl_playdateDate setFrame:CGRectMake(20, lbl_playdateLocation.frame.origin.y+lbl_playdateLocation.frame.size.height+3, size.width, size.height)];
		
		size = [lbl_playdateDuration.text sizeWithFont:lbl_playdateDuration.font constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:lbl_playdateDuration.lineBreakMode];
		[lbl_playdateDuration setFrame:CGRectMake(20, lbl_playdateDate.frame.origin.y+lbl_playdateDate.frame.size.height, size.width, size.height)];
		
		size = [lbl_organizer.text sizeWithFont:lbl_organizer.font constrainedToSize:CGSizeMake(100, FLT_MAX) lineBreakMode:lbl_organizer.lineBreakMode];
		[lbl_organizer setFrame:CGRectMake(20, lbl_playdateDuration.frame.origin.y+lbl_playdateDuration.frame.size.height+5, size.width, size.height)];
		
		size = [lbl_orgaizerName.text sizeWithFont:lbl_orgaizerName.font constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:lbl_orgaizerName.lineBreakMode];
		[lbl_orgaizerName setFrame:CGRectMake(lbl_organizer.frame.origin.x+lbl_organizer.frame.size.width+2, lbl_playdateDuration.frame.origin.y+lbl_playdateDuration.frame.size.height+5, size.width, size.height)];
		float hightBackgroundView =0;
		if (btn_cancel.hidden) {
			hightBackgroundView = lbl_organizer.frame.origin.y+lbl_organizer.frame.size.height+10;
		}else {
			[btn_cancel setFrame:CGRectMake(20, lbl_organizer.frame.origin.y+lbl_organizer.frame.size.height+8, 76, 23)];
			hightBackgroundView = btn_cancel.frame.origin.y+btn_cancel.frame.size.height+10;
		}

		UIView *vi_background = [cell.contentView viewWithTag:1001];
		vi_background.backgroundColor =[UIColor colorWithRed:0.933 green:0.949 blue:0.961 alpha:1.0];
		[vi_background setFrame:CGRectMake(5, 5, 270, hightBackgroundView)];
		return cell;
		
	}else if ([strLabel isEqualToString:@"RSVPCell"]) {
		NSString *userInfoCell = @"RSVPCell";
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.backgroundColor = [UIColor colorWithRed:0.933 green:0.949 blue:0.961 alpha:1.0];
			
			UIView *vi_background = [[UIView alloc]initWithFrame:CGRectZero];
			[vi_background setFrame:CGRectMake(5, 5, 270, 55)];
			vi_background.tag = 1001;
			vi_background.layer.borderColor = [UIColor grayColor].CGColor;
			vi_background.backgroundColor = [UIColor colorWithRed:0.933 green:0.949 blue:0.961 alpha:1.0];
			vi_background.layer.cornerRadius = 10.0;
			vi_background.layer.borderWidth = 1.0;
			[cell.contentView addSubview:vi_background];
			[vi_background release];
			
			UIButton *btn_Yes = [UIButton buttonWithType:UIButtonTypeCustom];
			[btn_Yes setFrame:CGRectMake(20, 20, 70, 25)];
			btn_Yes.tag = 201;
			[btn_Yes setTitle:@"Yes" forState:UIControlStateNormal];
			btn_Yes.titleLabel.font = [UIFont boldSystemFontOfSize:12];
			[btn_Yes addTarget:self action:@selector(RSVPClicked:) forControlEvents:UIControlEventTouchUpInside];
			[btn_Yes setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"customBtn_dashboard")] forState:UIControlStateNormal];
			[cell.contentView addSubview:btn_Yes];
			
			UIButton *btn_No = [UIButton buttonWithType:UIButtonTypeCustom];
			btn_No.tag = 202;
			[btn_No setTitle:@"No" forState:UIControlStateNormal];
			btn_No.titleLabel.font = [UIFont boldSystemFontOfSize:12];
			[btn_No setFrame:CGRectMake(105, 20, 70, 25)];
			[btn_No addTarget:self action:@selector(RSVPClicked:) forControlEvents:UIControlEventTouchUpInside];
			[btn_No setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"customBtn_dashboard")] forState:UIControlStateNormal];
			[cell.contentView addSubview:btn_No];
			
			UIButton *btn_MayBe = [UIButton buttonWithType:UIButtonTypeCustom];
			btn_MayBe.tag = 203;
			[btn_MayBe setTitle:@"Maybe" forState:UIControlStateNormal];
			btn_MayBe.titleLabel.font = [UIFont boldSystemFontOfSize:12];
			[btn_MayBe setFrame:CGRectMake(190, 20, 70, 25)];
			[btn_MayBe addTarget:self action:@selector(RSVPClicked:) forControlEvents:UIControlEventTouchUpInside];
			[btn_MayBe setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"customBtn_dashboard")] forState:UIControlStateNormal];
			[cell.contentView addSubview:btn_MayBe];
		}
		
		UIButton *btn_Yes = (UIButton *)[cell.contentView viewWithTag:201];
		UIButton *btn_No = (UIButton *)[cell.contentView viewWithTag:202];
		UIButton *btn_MayBe = (UIButton *)[cell.contentView viewWithTag:203];
		
		if ([self.dict_participants objectForKey:@"selfData"]) {
			if ([[[self.dict_participants objectForKey:@"selfData"] objectForKey:@"status"] isEqualToString:@"MAYBE"]) {
				[btn_MayBe setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_commonBlueDashboard")] forState:UIControlStateNormal];
			}
			if ([[[self.dict_participants objectForKey:@"selfData"] objectForKey:@"status"] isEqualToString:@"YES"]) {
				[btn_Yes setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_commonBlueDashboard")] forState:UIControlStateNormal];
			}
			if ([[[self.dict_participants objectForKey:@"selfData"] objectForKey:@"status"] isEqualToString:@"NO"]) {
				[btn_No setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_commonBlueDashboard")] forState:UIControlStateNormal];
			}
		}
		return cell;
	}else if ([strLabel isEqualToString:@"MessageCell"]) {
		NSString *userInfoCell = @"MessageCell";
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
//			cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
            cell.backgroundColor = [UIColor whiteColor];
			
			UIView *vi_background = [[UIView alloc]initWithFrame:CGRectZero];
			vi_background.tag = 1001;
			vi_background.layer.borderColor = [UIColor grayColor].CGColor;
//			vi_background.backgroundColor = [UIColor groupTableViewBackgroundColor];
            vi_background.backgroundColor = [UIColor whiteColor];
			vi_background.layer.cornerRadius = 10.0;
			vi_background.layer.borderWidth = 1.0;
			[cell.contentView addSubview:vi_background];
			vi_background.clipsToBounds = YES;
			[vi_background release];
			
//			UIImageView *img_tykeBoard = [[UIImageView alloc]initWithFrame:CGRectMake(15, 20, 111, 24)];
			UIImageView *img_tykeBoard = [[UIImageView alloc]initWithFrame:CGRectMake(80, 10, 111, 24)];
			[img_tykeBoard setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"img_tykeBoard")]];
			[cell.contentView addSubview:img_tykeBoard];
			[img_tykeBoard release];
			
			UIButton *btn_addNewMessage = [UIButton buttonWithType:UIButtonTypeContactAdd];
			[btn_addNewMessage setTitle:@"Add New" forState:UIControlStateNormal];
//			[btn_addNewMessage setFrame:CGRectMake(15, 50, 30, 30)];
			[btn_addNewMessage setFrame:CGRectMake(240, 8, 30, 30)];
			[btn_addNewMessage addTarget:self action:@selector(PostMessage:) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:btn_addNewMessage];
			
//			UILabel *lbl_addNew = [[UILabel alloc]initWithFrame:CGRectMake(55, 50, 100, 20)];
//			lbl_addNew.text = @"Add New";
//			lbl_addNew.backgroundColor = [UIColor clearColor];
//			lbl_addNew.font = [UIFont systemFontOfSize:14];
//			lbl_addNew.textColor = [UIColor lightGrayColor];
//			[cell.contentView addSubview:lbl_addNew];
//			[lbl_addNew release];
			
			//UILabel *lbl_Message = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 200, 20)];
//			lbl_Message.text = @"Message";
//			lbl_Message.tag = 11;
//			lbl_Message.textColor = [UIColor colorWithRed:0.298 green:0.318 blue:0.396 alpha:1];
//			lbl_Message.backgroundColor = [UIColor clearColor];
//			[cell.contentView addSubview:lbl_Message];
//			[lbl_Message release];
			
			UILabel *lbl_MessageFrom = [[UILabel alloc]initWithFrame:CGRectMake(10, 60, 100, 20)];
			lbl_MessageFrom.tag = 12;
			[lbl_MessageFrom setTextColor:[UIColor colorWithRed:0.161 green:0.235 blue:0.404 alpha:1]];
			[lbl_MessageFrom setFont:[UIFont boldSystemFontOfSize:13]];
			lbl_MessageFrom.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:lbl_MessageFrom];
			[lbl_MessageFrom release];
			
			UILabel *lbl_messageTimestamp = [[UILabel alloc]initWithFrame:CGRectMake(110, 60, 150, 20)];
			lbl_messageTimestamp.tag = 13;
			[lbl_messageTimestamp setTextColor:[UIColor colorWithRed:0.161 green:0.235 blue:0.404 alpha:1]];
			[lbl_messageTimestamp setFont:[UIFont systemFontOfSize:13]];
			lbl_messageTimestamp.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:lbl_messageTimestamp];
			[lbl_messageTimestamp release];
			
			UILabel *lbl_playdateMessage = [[UILabel alloc]initWithFrame:CGRectMake(10, 50, 200, 40)];
			lbl_playdateMessage.tag = 14;
			lbl_playdateMessage.numberOfLines = 0;
			lbl_playdateMessage.font =[UIFont systemFontOfSize:15];
			[lbl_playdateMessage setTextColor:[UIColor grayColor]];
			lbl_playdateMessage.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:lbl_playdateMessage];
			[lbl_playdateMessage release];
			
		}
//		UILabel *lbl_Message = (UILabel *)[cell.contentView viewWithTag:11];
		UILabel *lbl_MessageFrom = (UILabel *)[cell.contentView viewWithTag:12];
		UILabel *lbl_messageTimestamp = (UILabel *)[cell.contentView viewWithTag:13];
		UILabel *lbl_playdateMessage = (UILabel *)[cell.contentView viewWithTag:14];
		
		if ([[self.dict_data objectForKey:@"playdateMessage"] length] > 0) {
			lbl_playdateMessage.text = [self.dict_data objectForKey:@"playdateMessage"];
			
			lbl_MessageFrom.text = @"message from:";
			if ([self.dict_data objectForKey:@"playdateCreateTimestamp"]) {
				NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//				NSArray *arr = [[self.dict_data objectForKey:@"playdateCreateTimestamp"] componentsSeparatedByString:@"."];
//				NSString *str_time = [arr objectAtIndex:0];
				[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SZ"];
//				NSDate *dt1 = [formatter dateFromString:str_time];
				NSDate *dt1 = [formatter dateFromString:[self.dict_data objectForKey:@"playdateCreateTimestamp"]];
				[formatter setDateStyle:NSDateFormatterMediumStyle];
				NSString *str_label = [formatter stringFromDate:dt1];
				[formatter setDateFormat:@"h:mm a"];
				NSString *str =	[formatter stringFromDate:dt1];
				lbl_messageTimestamp.text = [NSString stringWithFormat:@"%@ %@",str_label,str];
				[formatter release];
			}
			
			if ([self.dict_data objectForKey:@"OrganiserFName"] && [self.dict_data objectForKey:@"OrganiserLName"]) {
				lbl_MessageFrom.text = [NSString stringWithFormat:@"%@ %@ : ",[self.dict_data objectForKey:@"OrganiserFName"],[self.dict_data objectForKey:@"OrganiserLName"]];
			}
		}

        CGSize sizeForFirstName = [lbl_MessageFrom.text sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:CGSizeMake(200, FLT_MAX)];
        lbl_MessageFrom.frame = CGRectMake(20, 40, sizeForFirstName.width, sizeForFirstName.height);
        
        CGSize sizeForTimestamp = [lbl_messageTimestamp.text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(150, FLT_MAX)];
        lbl_messageTimestamp.frame = CGRectMake(lbl_MessageFrom.frame.origin.x+lbl_MessageFrom.frame.size.width+5, 40, sizeForTimestamp.width, sizeForTimestamp.height);
        
        CGSize sizeForMessage = [lbl_playdateMessage.text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(240, FLT_MAX)];
        lbl_playdateMessage.frame = CGRectMake(20, lbl_MessageFrom.frame.origin.y+lbl_MessageFrom.frame.size.height+3, sizeForMessage.width, sizeForMessage.height);

		if (lbl_playdateMessage.frame.size.height > 1) {
			heightForFirstMessage = lbl_playdateMessage.frame.size.height+76;
		}else {
			heightForFirstMessage = lbl_playdateMessage.frame.size.height+70;
		}
		
		if (![vi_messagesCellView superview]) {
			[cell.contentView addSubview:vi_messagesCellView];
			[vi_messagesCellView release];
		}
		
		UIView *vi_background = (UIView *)[cell.contentView viewWithTag:1001];
		vi_background.frame = CGRectMake(5, 5, 270, heightForFirstMessage+vi_messagesCellView.frame.size.height);
		
		return cell;
	}else {
		NSString *userInfoCell = @"YESNOMAYBECell";
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIView *viBack = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
			[viBack setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"cellBack.png"]]];
			viBack.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
			[cell.contentView addSubview:viBack];
			[viBack release];
			
			UILabel *lbl_childName = [[UILabel alloc]initWithFrame:CGRectMake(20, 7, 220, 15)];
			lbl_childName.backgroundColor = [UIColor clearColor];
			lbl_childName.tag = 41;
			lbl_childName.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			[lbl_childName setFont:[UIFont boldSystemFontOfSize:13]];
			[cell.contentView addSubview:lbl_childName];
			[lbl_childName release];
			
			UILabel *lbl_parentName = [[UILabel alloc]initWithFrame:CGRectMake(20, 22, 220, 15)];
			lbl_parentName.backgroundColor = [UIColor clearColor];
			[lbl_parentName setFont:[UIFont systemFontOfSize:14]];
			lbl_parentName.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			lbl_parentName.tag = 42;
			[cell.contentView addSubview:lbl_parentName];
			[lbl_parentName release];
		}
		
		NSArray *arr = nil;
		if ([strLabel isEqualToString:@"YesAttendingCell"]) {
			arr = [self.dict_participants objectForKey:@"YesAttending"];
		}else if([strLabel isEqualToString:@"NoAttendingCell"]){
			arr = [self.dict_participants objectForKey:@"NoAttending"];			
		}else if([strLabel isEqualToString:@"MaybeAttendingCell"]){
			arr = [self.dict_participants objectForKey:@"MaybeAttending"];			
		}
			
		
		UILabel *lbl_childName = (UILabel *)[cell.contentView viewWithTag:41];
		UILabel *lbl_parentName  = (UILabel *)[cell.contentView viewWithTag:42];

		if ([[arr objectAtIndex:indexPath.row] objectForKey:@"firstName"] && [[arr objectAtIndex:indexPath.row] objectForKey:@"lastName"]) {
			lbl_childName.text = [NSString stringWithFormat:@"%@ %@",[[arr objectAtIndex:indexPath.row] objectForKey:@"firstName"],[[arr objectAtIndex:indexPath.row] objectForKey:@"lastName"]];
		}
		if ([[arr objectAtIndex:indexPath.row] objectForKey:@"parentFName"] && [[arr objectAtIndex:indexPath.row] objectForKey:@"parentLName"]) {
			lbl_parentName.text =[NSString stringWithFormat:@"%@ %@",[[arr objectAtIndex:indexPath.row] objectForKey:@"parentFName"],[[arr objectAtIndex:indexPath.row] objectForKey:@"parentLName"]];
		}
		return cell;	
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UITableView Components Methods

- (void) RSVPClicked : (id) sender {
	
	UIButton *btn = (UIButton *)sender;
	[DELEGATE addLoadingView:self.vi_main];
	switch (btn.tag) {
		case 201:
			[api_tyke postRSVP:self.playdate_id RSVPStatus:@"YES"];
			self.RSVPAccepted = YES;
			break;
		case 202:
			[api_tyke postRSVP:self.playdate_id RSVPStatus:@"NO"];
			break;
		case 203:
			[api_tyke postRSVP:self.playdate_id RSVPStatus:@"MAYBE"];
			break;
		default:
			break;
	}

}

- (CustomSegmentView *)createSegmentViewWithFrame:(CGRect)frame {

	NSMutableArray *arr_segments = [[NSMutableArray alloc]init];
	
	NSMutableDictionary *dict_accept = [[NSMutableDictionary alloc]init];
	[dict_accept setObject:@"seg_yesNoYesSelected@2x.png" forKey:@"imageName"];
	[dict_accept setObject:@"" forKey:@"title"];
	[arr_segments addObject:dict_accept];
	[dict_accept release];
	
	NSMutableDictionary *dict_decline = [[NSMutableDictionary alloc]init];
	[dict_decline setObject:@"seg_yesNoNoSelected@2x.png" forKey:@"imageName"];
	[dict_decline setObject:@"" forKey:@"title"];
	[arr_segments addObject:dict_decline];
	[dict_decline release];
	
	NSMutableDictionary *dict_ignore = [[NSMutableDictionary alloc]init];
	[dict_ignore setObject:@"seg_yesNoMaybeSelected@2x.png" forKey:@"imageName"];
	[dict_ignore setObject:@"" forKey:@"title"];
	[arr_segments addObject:dict_ignore];
	[dict_ignore release];
	
	CustomSegmentView *seg_control = [[[CustomSegmentView alloc]initWithFrame:frame withSegments:[arr_segments autorelease] defaultImage:@"seg_yesNoDeselected@2x.png" andDelegate:self] autorelease];
	[seg_control setBackgroundColor:[UIColor clearColor]];
	
	return seg_control;
}
- (void) segementIndexChanged : (CustomSegmentView*) sender callAPI:(BOOL)callAPI {
/*	CustomSegmentView *seg_control = (CustomSegmentView *)sender;
	NSMutableDictionary *dict = [self.arr_participants objectAtIndex:seg_control.tag-1000];
	[dict setObject:[NSString stringWithFormat:@"%d",seg_control.selectedIndex] forKey:@"SelectedSegment"];
	if (callAPI) {
		switch (seg_control.selectedIndex) {
			case 1:
				[DELEGATE addLoadingView:self.vi_main];
				[api_tyke postRSVP:self.playdate_id RSVPStatus:@"YES"];			
				break;
			case 2:
				[DELEGATE addLoadingView:self.vi_main];
				[api_tyke postRSVP:self.playdate_id RSVPStatus:@"NO"];			
				break;
			case 3:
				[DELEGATE addLoadingView:self.vi_main];
				[api_tyke postRSVP:self.playdate_id RSVPStatus:@"MAYBE"];
				break;
			default:
				break;
		}
	}
	//if ([[dict objectForKey:@"valueUpdated"] isEqualToString:@"NO"]) {
	//	[dict setObject:@"YES" forKey:@"valueUpdated"];
//	}else {
//		
//		[dict setObject:@"NO" forKey:@"valueUpdated"];
//	}

*/
}

- (void) PostMessage : (id) sender {
		[self addMessageView];
}

- (void) cancelPlayDate : (id) sender {
	
	UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Confirm"
												   message:@"Do you really want to cancel this playdate?"
												  delegate:self cancelButtonTitle:@"No" 
										 otherButtonTitles:@"Yes",nil];
	[alert setTag:300];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if(alertView.tag == 300) {
		if (buttonIndex == 1) {
			[DELEGATE addLoadingView:self.vi_main];
			[api_tyke cancelPlaydate:self.playdate_id];
		}
	}
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
	txt_messageView.delegate = self;
	txt_messageView.font = [UIFont boldSystemFontOfSize:16];
	txt_messageView.backgroundColor = [UIColor whiteColor];
	[txt_messageView becomeFirstResponder];
	[txt_messageView setKeyboardAppearance:UIKeyboardAppearanceDefault];
	[self.MessageView addSubview:txt_messageView];
	[txt_messageView release];
	
	UINavigationItem *nav_item = [[UINavigationItem alloc] init];
	nav_item.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Add Message"];
	UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 221, 320, 44)];
	navBar.tag = 1111;
//	[navBar setTintColor:[UIColor colorWithRed:0.623 green:0.850 blue:0.996 alpha:1]];
	
	
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

- (void) btnCancelClicked : (id) sender {
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

- (void) btnDoneClicked : (id) sender {
	NSString *txtMessage = [[[self.MessageView subviews] objectAtIndex:0] text];
	if ([txtMessage length]) {
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke postWallMessage:self.playdate_id Message:txtMessage];
		
        [[[self.MessageView subviews] objectAtIndex:0] resignFirstResponder];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.66];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeMessageView)];
        self.MessageView.frame = CGRectOffset(self.MessageView.frame, 0, 480);
        [UIView commitAnimations];
        
    }

}

- (void) saveEventToCalendar {
    if ([self.dict_data objectForKey:@"date"] && [self.dict_data objectForKey:@"StartTime"] && [self.dict_data objectForKey:@"endDate"] && [self.dict_data objectForKey:@"EndTime"]){

        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"HH:mm yyyy-MM-dd"];
        
        NSString *fullStartDateString = [NSString stringWithFormat:@"%@ %@", [self.dict_data objectForKey:@"StartTime"], [self.dict_data objectForKey:@"date"]];
//        NSString *fullEndDateString = [NSString stringWithFormat:@"%@ %@", [self.dict_data objectForKey:@"EndTime"], [self.dict_data objectForKey:@"endDate"]];

        NSDate *startTime = [formatter dateFromString:fullStartDateString];
//        NSDate *endTime = [formatter dateFromString:fullEndDateString];
        
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        
        EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
        event.title     = DefaultStringValue([self.dict_data objectForKey:@"playdateName"]);
        
        event.startDate = startTime;
        event.endDate   = [startTime dateByAddingTimeInterval:600];
        
//        NSLog([startTime description]);
//        NSLog([endTime description]);        
        
        [event setCalendar:[eventStore defaultCalendarForNewEvents]];
        NSError *err;
        [eventStore saveEvent:event span:EKSpanThisEvent error:&err];       
        
        if (err != nil) {
            NSLog(@"Error while saving calendar event: %@", err);
        }
        
    }
}

#pragma mark -
#pragma mark API Call Response

- (void) postRSVPResponse : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
        
        if (self.RSVPAccepted) {
//            [self saveEventToCalendar];
        }
        
		[self popViewController];
	}		
//	if (self.RSVPAccepted) {
//		int index = [[self.navigationController viewControllers] indexOfObject:self];
//		
//		if ([[[self.navigationController viewControllers] objectAtIndex:index-1] isKindOfClass:[MessagesViewController class]]) {
//			[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MESSAGE_LIST_CHANGED object:self.playdate_id userInfo:nil];
//		}else {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"Playdate RSVP Changed" object:self userInfo:nil];
//		}
//	}

}
- (void) CancelPlaydateResponse : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Playdate" 
													   message:@"Playdate canceled."
													  delegate:nil cancelButtonTitle:@"Ok" 
											 otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		DashboardViewController *dashboard =[[self.navigationController viewControllers] objectAtIndex:0];
		NSMutableArray *arr_activities =[dashboard.dict_data objectForKey:@"Activities"];
		for (int i= 0;i < [arr_activities count];i++) {
			if ([[[arr_activities objectAtIndex:i] objectForKey:@"txtPid"] isEqualToString:self.playdate_id]) {
				[arr_activities removeObjectAtIndex:i];
				break;
			}
		}
		[self popViewController];
	}

}
- (void) postWallMsgResp : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thank you" 
													   message:@"Message Posted Successfully"
													  delegate:nil cancelButtonTitle:@"Ok" 
											 otherButtonTitles:nil];
		[alert show];
		[alert release];

		if (!self.arr_messages) {
			self.arr_messages = [[NSMutableArray alloc]init];
		}
		NSString *txtMessage = [[[self.MessageView subviews] objectAtIndex:0] text];
		NSMutableDictionary *dict_message = [[NSMutableDictionary alloc]init];
		[dict_message setObject:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"fname"]  forKey:@"firstName"];
		[dict_message setObject:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"lname"]  forKey:@"lastName"];
		[dict_message setObject:txtMessage forKey:@"message"];
        
        NSDate *current_timestamp = [[NSDate alloc] init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SZ"];
        
        [dict_message setObject:[formatter stringFromDate:current_timestamp] forKey:@"time"];
        [formatter release];
        [current_timestamp release];

		[self.arr_messages addObject:dict_message];
		[dict_message release];
	[self.theTableView reloadData];
		
	}		
}

- (void) getPlayDateDetailsResp : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
//	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		self.dict_data = [response objectForKey:@"response"];
		[api_tyke getPlaydateParticipants:[[response objectForKey:@"response"] objectForKey:@"playdateID"]];
	}
}	
- (void) getPlaydateParticipantsResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
//	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		[self sortParticipants:response];
		[api_tyke getWallMessages:self.playdate_id txTime:@"0"];
//		[self.theTableView reloadData];
	}
}

- (void) getWallMessagesResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
			if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
				self.arr_messages = [[response objectForKey:@"response"] objectForKey:@"messages"];
				[self.theTableView reloadData];
			}
}

-(void) sortParticipants : (NSDictionary *) response {

	//status YES;
	
	NSMutableArray *arr_Yes = [[NSMutableArray alloc]init];
	NSMutableArray *arr_No =  [[NSMutableArray alloc]init];
	NSMutableArray *arr_Maybe =  [[NSMutableArray alloc]init];
	
	for (NSDictionary *dict in [[response objectForKey:@"response"] objectForKey:@"Participants"]) {
		if ([[dict objectForKey:@"status"] isEqualToString:@"YES"]) {
			[arr_Yes addObject:dict];
		}else if ([[dict objectForKey:@"status"] isEqualToString:@"NO"]) {
			[arr_No addObject:dict];
		}else if ([[dict objectForKey:@"status"] isEqualToString:@"MAYBE"]) {
			[arr_Maybe addObject:dict];
		}
	}

	for (NSDictionary *dict in [[response objectForKey:@"response"] objectForKey:@"Participants"]) {
		if (![[dict objectForKey:@"organizerFlag"] intValue] && [[dict objectForKey:@"parentId"] isEqualToString:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"txtUserTblPk"]]) {
			[self.dict_participants setObject:dict forKey:@"selfData"];
			break;
		}
	}
	[self.dict_participants setObject:arr_Yes forKey:@"YesAttending"];
	[self.dict_participants setObject:arr_No forKey:@"NoAttending"];
	[self.dict_participants setObject:arr_Maybe forKey:@"MaybeAttending"];
	[arr_Yes release];
	[arr_No release];
	[arr_Maybe release];
}

#pragma mark -
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
	[DELEGATE removeLoadingView:self.view];
}

- (void) failWithError : (NSError*) error {
	[DELEGATE removeLoadingView:self.view];	
}

- (void) requestCanceled {
	[DELEGATE removeLoadingView:self.view];
}

- (void)dealloc {
	
	[self.dict_data release];
	[self.arr_messages release];
	[self.dict_participants release];
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}


@end
