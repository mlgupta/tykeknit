//
//  EventDetailViewController.m
//  TykeKnit
//
//  Created by Manish Gupta on 21/06/11.
//  Copyright 2011 Tykeknit. All rights reserved.
//

#import "EventDetailViewController.h"
#import "Global.h"
#import "JSON.h"


@implementation EventDetailViewController
@synthesize theTableView, dict_data,MessageView,arr_messages;

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
		int yAxis  = 0;//30+30+lbl_playdateMessage.frame.size.height;
        int ht = 0;

		for (int i=0; i < [self.arr_messages count]; i++) {
			UILabel *lbl_MessageFrom = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 20)];
			lbl_MessageFrom.tag = 12;
			[lbl_MessageFrom setTextColor:[UIColor colorWithRed:0.161 green:0.235 blue:0.404 alpha:1]];
//			[lbl_MessageFrom setFont:[UIFont boldSystemFontOfSize:13]];
            [lbl_MessageFrom setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12]];
			lbl_MessageFrom.backgroundColor = [UIColor clearColor];
			[vi_messagesCellView addSubview:lbl_MessageFrom];
			[lbl_MessageFrom release];
			
			UILabel *lbl_messageTimestamp = [[UILabel alloc]initWithFrame:CGRectMake(110, 10, 150, 20)];
			lbl_messageTimestamp.tag = 13;
//			lbl_messageTimestamp.text = @"May 22, 2011 3:30 PM";
			[lbl_messageTimestamp setTextColor:[UIColor colorWithRed:0.161 green:0.235 blue:0.404 alpha:1]];
//			[lbl_messageTimestamp setFont:[UIFont systemFontOfSize:13]];
            [lbl_messageTimestamp setFont:[UIFont fontWithName:@"helvetica Neue" size:12]];
			lbl_messageTimestamp.backgroundColor = [UIColor clearColor];
			[vi_messagesCellView addSubview:lbl_messageTimestamp];
			[lbl_messageTimestamp release];
			
			UILabel *lbl_playdateMessage = [[UILabel alloc]initWithFrame:CGRectMake(10, 22, 200, 40)];
			lbl_playdateMessage.tag = 14;
			lbl_playdateMessage.numberOfLines = 0;
//			lbl_playdateMessage.font =[UIFont systemFontOfSize:15];
            [lbl_playdateMessage setFont:[UIFont fontWithName:@"helvetica Neue" size:12]];
			//			lbl_playdateMessage.text = @"Hello all";
			[lbl_playdateMessage setTextColor:[UIColor grayColor]];
			lbl_playdateMessage.backgroundColor = [UIColor clearColor];
			[vi_messagesCellView addSubview:lbl_playdateMessage];
			[lbl_playdateMessage release];
			
			NSDictionary *dict = [self.arr_messages objectAtIndex:i];
			if ([dict objectForKey:@"txtMessage"]) {
				lbl_playdateMessage.text = [dict objectForKey:@"txtMessage"];
				
				if ([dict objectForKey:@"txtUserFName"] && [dict objectForKey:@"txtUserLName"]) {
					lbl_MessageFrom.text = [[NSString stringWithFormat:@"%@ %@ : ",[dict objectForKey:@"txtUserFName"],[dict objectForKey:@"txtUserLName"]] capitalizedString];
				}
			}
			
			if ([dict objectForKey:@"timestamp"]) {
				NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//				NSArray *arr = [[dict objectForKey:@"timestamp"] componentsSeparatedByString:@"."];
//				NSString *str_time = [arr objectAtIndex:0];
				[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SZ"];
//				NSDate *dt1 = [formatter dateFromString:str_time];
				NSDate *dt1 = [formatter dateFromString:[dict objectForKey:@"timestamp"]];
				[formatter setDateStyle:NSDateFormatterMediumStyle];
				NSString *str_label = [formatter stringFromDate:dt1];
				[formatter setDateFormat:@"h:mm a"];
				NSString *str =	[formatter stringFromDate:dt1];
				lbl_messageTimestamp.text = [NSString stringWithFormat:@"%@ %@",str_label,str];
				[formatter release];
			}
			
			
			CGSize sizeForFirstName = [lbl_MessageFrom.text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:12] constrainedToSize:CGSizeMake(200, FLT_MAX)];
			lbl_MessageFrom.frame = CGRectMake(10, yAxis, sizeForFirstName.width, sizeForFirstName.height);
			
			CGSize sizeForTimestamp = [lbl_messageTimestamp.text sizeWithFont:[UIFont fontWithName:@"helvetica Neue" size:12] constrainedToSize:CGSizeMake(130, FLT_MAX)];
			lbl_messageTimestamp.frame = CGRectMake(lbl_MessageFrom.frame.origin.x+lbl_MessageFrom.frame.size.width, yAxis, sizeForTimestamp.width, lbl_MessageFrom.frame.size.height);
			lbl_messageTimestamp.adjustsFontSizeToFitWidth = YES;
			
			CGSize sizeForMessage = [lbl_playdateMessage.text sizeWithFont:[UIFont fontWithName:@"helvetica Neue" size:12] constrainedToSize:CGSizeMake(240, FLT_MAX)];
			lbl_playdateMessage.frame = CGRectMake(10, yAxis + sizeForFirstName.height, sizeForMessage.width, sizeForMessage.height);
			
			ht = lbl_playdateMessage.frame.origin.y + lbl_playdateMessage.frame.size.height + 15;  
			yAxis = ht;
		}
		yAxis -= 30;
        vi_messagesCellView.frame = CGRectMake(0, 75, 260, yAxis);
	}
}

- (void)viewDidLoad {
	UIButton *btn = [DELEGATE getBackBarButton];
	[btn addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Event"];

	self.arr_messages  =[[NSMutableArray alloc]init];

    if (!api_tyke) {
		api_tyke = [[TykeKnitApi alloc]init];
		api_tyke.delegate = self;
	}
    
	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke getEventWallMessages:[self.dict_data objectForKey:@"txtEventTblPk"]];

	
    [self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];

    [super viewDidLoad];
	
}

#pragma mark -
#pragma mark tableView DELEGATE Methods

- (NSString *)getSectionLabelForSection:(int)section {
    
	NSString *str = nil;
	if (section == 0) {
		str = @"EventInfoCell";
	}else if (section == 1) {
		str = @"EventMessageCell";
	}
	return str;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	int RET = 0;
	
	NSString *strLabel = [self getSectionLabelForSection:indexPath.section];
	if ([strLabel isEqualToString:@"EventInfoCell"]) {
		if (self.dict_data) {
			CGSize sizeForName = [[self.dict_data objectForKey:@"txtEventTitle"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14] constrainedToSize:CGSizeMake(210, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			CGSize sizeForDetail = [[self.dict_data objectForKey:@"txtEventDetail"] sizeWithFont:[UIFont fontWithName:@"helvetica Neue" size:12] constrainedToSize:CGSizeMake(210, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			CGSize sizeForLocation = [[self.dict_data objectForKey:@"txtEventLocation"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10] constrainedToSize:CGSizeMake(210, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			CGSize sizeForDate =  [[self.dict_data objectForKey:@"txtSubmissionTimestamp"] sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			CGSize sizeForSubmittedBy = [[self.dict_data objectForKey:@"txtUserFName"] sizeWithFont:[UIFont fontWithName:@"helvetica Neue" size:10] constrainedToSize:CGSizeMake(210, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			RET = sizeForName.height+sizeForDetail.height+sizeForLocation.height+sizeForDate.height+sizeForSubmittedBy.height+30;
//			RET = sizeForName.height+sizeForDetail.height+sizeForSubmittedBy.height+20;
		}
	}else if ([strLabel isEqualToString:@"EventMessageCell"]) {
		if ([self.arr_messages count]) {
			[self drawMessagesCellView];
				RET = vi_messagesCellView.frame.size.height+100;
		}else {
				RET = 95;
		}
	}
	return RET;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	
	NSString *strLabel = [self getSectionLabelForSection:section];
	if ( [strLabel isEqualToString:@"EventMessageCell"]) {
		return 30;
	}else {
		return 0;
	}
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	
	UIView *vi = [[UIView alloc] initWithFrame:CGRectZero];
	NSString *strLabel = [self getSectionLabelForSection:section];
	if ( [strLabel isEqualToString:@"EventMessageCell"]) {
		vi.frame = CGRectMake(0, 0, 200, 30);
	}
	
	return [vi autorelease];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	self.theTableView.backgroundColor = [UIColor colorWithRed:0.875 green:0.906 blue:0.918 alpha:1.0];
	
	NSString *strLabel = [self getSectionLabelForSection:indexPath.section];
	if ([strLabel isEqualToString:@"EventInfoCell"]) {
		NSString *eventInfoCell = @"EventInfoCell";
		
		cell = [tableView dequeueReusableCellWithIdentifier:eventInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:eventInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.backgroundColor = [UIColor colorWithRed:0.933 green:0.949 blue:0.961 alpha:1.0];
			
			UIView *vi_background = [[UIView alloc]initWithFrame:CGRectZero];
			vi_background.tag = 1001;
			vi_background.layer.borderColor = [UIColor grayColor].CGColor;
			vi_background.layer.cornerRadius = 10.0;
			vi_background.layer.borderWidth = 1.0;
			[cell.contentView addSubview:vi_background];
			[vi_background release];

            UIImageView *event_in_knit_img = [[UIImageView alloc]initWithFrame:CGRectMake(13,13,13,13)];
            event_in_knit_img.tag = 6;
            event_in_knit_img.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:event_in_knit_img];
            [event_in_knit_img release];

			UILabel *lbl_eventTitle = [[UILabel alloc]initWithFrame:CGRectMake(35, 10, 210, 30)];
			lbl_eventTitle.backgroundColor = [UIColor clearColor];
			lbl_eventTitle.tag = 1;
            [lbl_eventTitle setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14]];
            lbl_eventTitle.textColor = [UIColor darkGrayColor];
            lbl_eventTitle.lineBreakMode = UILineBreakModeWordWrap;
            lbl_eventTitle.numberOfLines = 0;
            [lbl_eventTitle sizeToFit];
			[cell.contentView addSubview:lbl_eventTitle];
			[lbl_eventTitle release];

			UILabel *lbl_eventLocation = [[UILabel alloc]initWithFrame:CGRectMake(35, 30, 210, 10)];
			lbl_eventLocation.tag = 7;
			lbl_eventLocation.backgroundColor = [UIColor clearColor];
            [lbl_eventLocation setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10]];
			lbl_eventLocation.textColor = [UIColor grayColor];
            lbl_eventLocation.lineBreakMode = UILineBreakModeWordWrap;
            lbl_eventLocation.numberOfLines = 0;
            [lbl_eventLocation sizeToFit];
			[cell.contentView addSubview:lbl_eventLocation];
			[lbl_eventLocation release];

			UILabel *lbl_postedBy = [[UILabel alloc]initWithFrame:CGRectMake(35, 40, 210, 10)];
			lbl_postedBy.text = @"posted: ";
			lbl_postedBy.backgroundColor = [UIColor clearColor];
            [lbl_postedBy setFont:[UIFont fontWithName:@"helvetica Neue" size:10]];
			lbl_postedBy.textColor = [UIColor grayColor];
			lbl_postedBy.tag = 4;
			[cell.contentView addSubview:lbl_postedBy];
			[lbl_postedBy release];
			
			UILabel *postedBy_name = [[UILabel alloc]initWithFrame:CGRectMake(35, 40, 210, 10)];
			postedBy_name.backgroundColor = [UIColor clearColor];
            [postedBy_name setFont:[UIFont fontWithName:@"helvetica Neue" size:10]];
//			postedBy_name.textColor =  [UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];
			postedBy_name.textColor =  [UIColor grayColor];
			postedBy_name.tag = 5;
			[cell.contentView addSubview:postedBy_name];
			[postedBy_name release];
			
			UILabel *lbl_eventSubmissionDate = [[UILabel alloc]initWithFrame:CGRectMake(35, 50, 210, 10)];
			lbl_eventSubmissionDate.tag = 3;
			lbl_eventSubmissionDate.backgroundColor =[UIColor clearColor];
            [lbl_eventSubmissionDate setFont:[UIFont fontWithName:@"helvetica Neue" size:10]];
			lbl_eventSubmissionDate.textColor = [UIColor colorWithRed:0.161 green:0.235 blue:0.504 alpha:1];
			[cell.contentView addSubview:lbl_eventSubmissionDate];
			[lbl_eventSubmissionDate release];

			UILabel *lbl_eventDetail = [[UILabel alloc]initWithFrame:CGRectMake(35, 70, 210, 10)];
			lbl_eventDetail.tag = 2;
			lbl_eventDetail.backgroundColor = [UIColor clearColor];
            [lbl_eventDetail setFont:[UIFont fontWithName:@"helvetica Neue" size:12]];
			lbl_eventDetail.textColor = [UIColor grayColor];
            lbl_eventDetail.lineBreakMode = UILineBreakModeWordWrap;
            lbl_eventDetail.numberOfLines = 0;
            [lbl_eventDetail sizeToFit];
			[cell.contentView addSubview:lbl_eventDetail];
			[lbl_eventDetail release];
}
		
		UILabel *lbl_eventTitle = (UILabel *)[cell.contentView viewWithTag:1];
		UILabel *lbl_eventDetail = (UILabel *)[cell.contentView viewWithTag:2];
		UILabel *lbl_eventLocation = (UILabel *)[cell.contentView viewWithTag:7];
		UILabel *lbl_eventSubmissionDate = (UILabel *)[cell.contentView viewWithTag:3];
		UILabel *lbl_postedBy = (UILabel *)[cell.contentView viewWithTag:4];
		UILabel *postedBy_name = (UILabel *)[cell.contentView viewWithTag:5];
        UIImageView *event_in_knit_img = (UIImageView *)[cell.contentView viewWithTag:6];

		
        lbl_eventTitle.text = [self.dict_data objectForKey:@"txtEventTitle"];
        lbl_eventDetail.text = [self.dict_data objectForKey:@"txtEventDetail"];
        if ([[self.dict_data objectForKey:@"txtEventLocation"] length]) {
            lbl_eventLocation.text = [NSString stringWithFormat:@"%@",[self.dict_data objectForKey:@"txtEventLocation"]];
        }
        postedBy_name.text = [NSString stringWithFormat:@"%@ %@",[self.dict_data objectForKey:@"txtUserFName"],[self.dict_data objectForKey:@"txtUserLName"]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//        NSArray *arr = [[self.dict_data objectForKey:@"txtSubmissionTimestamp"] componentsSeparatedByString:@"."];
//        NSString *str_time = [arr objectAtIndex:0];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SZ"];
//        NSDate *dt1 = [formatter dateFromString:str_time];
        NSDate *dt1 = [formatter dateFromString:[self.dict_data objectForKey:@"txtSubmissionTimestamp"]];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        NSString *str_label = [formatter stringFromDate:dt1];
        [formatter setDateFormat:@"h:mm a"];
        NSString *str =	[formatter stringFromDate:dt1];
        lbl_eventSubmissionDate.text = [NSString stringWithFormat:@"%@ %@",str_label,str];
        [formatter release];

		
		CGSize size = [lbl_eventTitle.text sizeWithFont:lbl_eventTitle.font constrainedToSize:CGSizeMake(210, FLT_MAX) lineBreakMode:lbl_eventTitle.lineBreakMode];
		[lbl_eventTitle setFrame:CGRectMake(35, 10, size.width, size.height)];
		
		if ([[self.dict_data objectForKey:@"txtEventLocation"] length]) {
            size = [lbl_eventLocation.text sizeWithFont:lbl_eventLocation.font constrainedToSize:CGSizeMake(210, FLT_MAX) lineBreakMode:lbl_eventLocation.lineBreakMode];
            [lbl_eventLocation setFrame:CGRectMake(35, lbl_eventTitle.frame.origin.y+lbl_eventTitle.frame.size.height, size.width, size.height)];

            size = [lbl_postedBy.text sizeWithFont:lbl_postedBy.font constrainedToSize:CGSizeMake(100, FLT_MAX) lineBreakMode:lbl_postedBy.lineBreakMode];
            [lbl_postedBy setFrame:CGRectMake(35, lbl_eventLocation.frame.origin.y+lbl_eventLocation.frame.size.height+3, size.width, size.height)];
            
            size = [postedBy_name.text sizeWithFont:postedBy_name.font constrainedToSize:CGSizeMake(210, FLT_MAX) lineBreakMode:postedBy_name.lineBreakMode];
            [postedBy_name setFrame:CGRectMake(lbl_postedBy.frame.origin.x+lbl_postedBy.frame.size.width, lbl_eventLocation.frame.origin.y+lbl_eventLocation.frame.size.height+3, size.width, size.height)];
        }
        else {
            size = [lbl_postedBy.text sizeWithFont:lbl_postedBy.font constrainedToSize:CGSizeMake(100, FLT_MAX) lineBreakMode:lbl_postedBy.lineBreakMode];
            [lbl_postedBy setFrame:CGRectMake(35, lbl_eventTitle.frame.origin.y+lbl_eventTitle.frame.size.height+3, size.width, size.height)];
            
            size = [postedBy_name.text sizeWithFont:postedBy_name.font constrainedToSize:CGSizeMake(210, FLT_MAX) lineBreakMode:postedBy_name.lineBreakMode];
            [postedBy_name setFrame:CGRectMake(lbl_postedBy.frame.origin.x+lbl_postedBy.frame.size.width, lbl_eventTitle.frame.origin.y+lbl_eventTitle.frame.size.height+3, size.width, size.height)];
        }

		size = [lbl_eventSubmissionDate.text sizeWithFont:lbl_eventSubmissionDate.font constrainedToSize:CGSizeMake(210, FLT_MAX) lineBreakMode:lbl_eventSubmissionDate.lineBreakMode];
		[lbl_eventSubmissionDate setFrame:CGRectMake(35, lbl_postedBy.frame.origin.y+lbl_postedBy.frame.size.height, size.width, size.height)];
        
		size = [lbl_eventDetail.text sizeWithFont:lbl_eventDetail.font constrainedToSize:CGSizeMake(210, FLT_MAX) lineBreakMode:lbl_eventDetail.lineBreakMode];
		[lbl_eventDetail setFrame:CGRectMake(35, lbl_eventSubmissionDate.frame.origin.y+lbl_eventSubmissionDate.frame.size.height+10, size.width, size.height)];


        if ([[self.dict_data objectForKey:@"txtEventSubmitterInKnitFlag"] isEqualToString:@"1"]) {
            event_in_knit_img.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_InKnit")];
        }

		UIView *vi_background = [cell.contentView viewWithTag:1001];
		vi_background.backgroundColor =[UIColor colorWithRed:0.933 green:0.949 blue:0.961 alpha:1.0];
		[vi_background setFrame:CGRectMake(5, 5, 270, 0)];
		return cell;
	}else if ([strLabel isEqualToString:@"EventMessageCell"]) {
		NSString *msgInfoCell = @"EventMessageCell";
		cell = [tableView dequeueReusableCellWithIdentifier:msgInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:msgInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
//			cell.backgroundColor = [UIColor groupTableViewBackgroundColor];
			
			UIView *vi_background = [[UIView alloc]initWithFrame:CGRectZero];
			vi_background.tag = 1001;
			vi_background.layer.borderColor = [UIColor grayColor].CGColor;
//			vi_background.backgroundColor = [UIColor groupTableViewBackgroundColor];
			vi_background.layer.cornerRadius = 10.0;
			vi_background.layer.borderWidth = 1.0;
			[cell.contentView addSubview:vi_background];
			vi_background.clipsToBounds = YES;
			[vi_background release];
			
//			UIImageView *img_tykeBoard = [[UIImageView alloc]initWithFrame:CGRectMake(15, 5, 111, 24)];
			UIImageView *img_tykeBoard = [[UIImageView alloc]initWithFrame:CGRectMake(70, 8, 111, 24)];
			[img_tykeBoard setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"img_tykeBoard")]];
			[cell.contentView addSubview:img_tykeBoard];
			[img_tykeBoard release];

			UIButton *btn_addNewMessage = [UIButton buttonWithType:UIButtonTypeContactAdd];
			[btn_addNewMessage setTitle:@"Add New" forState:UIControlStateNormal];
			[btn_addNewMessage setFrame:CGRectMake(225, 5, 30, 30)];
			[btn_addNewMessage addTarget:self action:@selector(PostMessage:) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:btn_addNewMessage];
            
            UILabel *lbl_info = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 240, 30)];
            lbl_info.text = @"Attended this event? Know more about it? Use this space to share it with other parents.";
            lbl_info.numberOfLines = 0;
            [lbl_info setShadowColor:[UIColor whiteColor]];
            [lbl_info setLineBreakMode:UILineBreakModeWordWrap];
            [lbl_info setShadowOffset:CGSizeMake(0, 1)];
//            [lbl_info setFont:[UIFont systemFontOfSize:10]];
            [lbl_info setFont:[UIFont fontWithName:@"helvetica Neue" size:10]];
            [lbl_info setBackgroundColor:[UIColor clearColor]];
            [lbl_info setTextColor:blueTextColor];
            [lbl_info setTextAlignment:UITextAlignmentCenter];
            [cell.contentView addSubview:lbl_info];
            [lbl_info release];
		}
        
        if (![vi_messagesCellView superview]) {
			[cell.contentView addSubview:vi_messagesCellView];
			[vi_messagesCellView release];
		}

/*        
		UIView *vi_background = (UIView *)[cell.contentView viewWithTag:1001];
//		vi_background.frame = CGRectMake(5, 5, 270, heightForFirstMessage+vi_messagesCellView.frame.size.height);
		vi_background.frame = CGRectMake(0, 0, 260, 100+vi_messagesCellView.frame.size.height);
*/		
		return cell;
	}
	return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark UITableView Components Methods

- (void) PostMessage : (id) sender {
    [self addMessageView];
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
		[api_tyke postEventWallMessage:[self.dict_data objectForKey:@"txtEventTblPk"]     txtEventWallMessage:txtMessage];
		
        [[[self.MessageView subviews] objectAtIndex:0] resignFirstResponder];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.66];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(removeMessageView)];
        self.MessageView.frame = CGRectOffset(self.MessageView.frame, 0, 480);
        [UIView commitAnimations];
        
    }
    
}

#pragma mark -
#pragma mark API Call Response

- (void) postEventWallResponse : (NSData*)data {
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
		[dict_message setObject:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"fname"]  forKey:@"txtUserFName"];
		[dict_message setObject:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"lname"]  forKey:@"txtUserLName"];
		[dict_message setObject:txtMessage forKey:@"txtMessage"];
        NSDate *current_timestamp = [[NSDate alloc] init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SZ"];

        [dict_message setObject:[formatter stringFromDate:current_timestamp] forKey:@"timestamp"];
        [formatter release];
        [current_timestamp release];
		[self.arr_messages addObject:dict_message];
		[dict_message release];
        [self.theTableView reloadData];
	}		
}


- (void) getEventWallMessagesResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
    if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
        self.arr_messages = [[response objectForKey:@"response"] objectForKey:@"messages"];
        [self.theTableView reloadData];
    }
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
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}

@end
