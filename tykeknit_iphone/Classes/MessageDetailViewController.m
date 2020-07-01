//
//  MessageDetailViewController.m
//  TykeKnit
//
//  Created by Ver on 12/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessageDetailViewController.h"
#import "MessagesViewController.h"
#import "ComposeMailViewController.h"
#import "JSON.h"

@implementation MessageDetailViewController
@synthesize theTableView,msgID,api_tyke,dict_messageData,msgType,msgStatus,bottomTabbar;
@synthesize dict_prevData,RSVPAccepted;
- (void) backClicked : (id) sender {
	[self popViewController];
}

- (void)viewDidLoad {
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Message Details"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	[self.navigationItem setHidesBackButton:YES];
	
	self.RSVPAccepted = NO;
	UIButton *btn_back = [DELEGATE getBackBarButton];
	btn_back.tag = 101;
	[btn_back addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	self.dict_messageData = [[NSMutableDictionary alloc]init];
	self.RSVPAccepted = NO;
	if (!api_tyke) {
		api_tyke = [[TykeKnitApi alloc]init];
		api_tyke.delegate = self;
	}
	
	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke getMessageDetails:[self.dict_prevData objectForKey:@"txtMsgId"] txtMessageType:[self.dict_prevData objectForKey:@"txtMsgType"]];
    [super viewDidLoad];
}
#pragma mark -
#pragma mark bottomTabbarMethods
- (void) addBottomTabbarForType:(NSString *)messageType {
	if ([messageType isEqualToString:@"M"]) {
		self.bottomTabbar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 370, 282, 54)];
		[self.bottomTabbar setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"CustomMessageTabbar")]];
		[self.vi_main addSubview:self.bottomTabbar];
		self.bottomTabbar.userInteractionEnabled = YES;
		[self.bottomTabbar release];
		
		UIButton *btn_rply = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_rply setFrame:CGRectMake(55, 10, 30, 30)];
		[btn_rply setBackgroundColor:[UIColor clearColor]];
		[btn_rply addTarget:self action:@selector(replyToMessage:) forControlEvents:UIControlEventTouchUpInside];
		[self.bottomTabbar addSubview:btn_rply];
		
		UIButton *btn_delete = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_delete setFrame:CGRectMake(210, 10, 30, 30)];
		[btn_delete setBackgroundColor:[UIColor clearColor]];
		[btn_delete addTarget:self action:@selector(deleteMessage:) forControlEvents:UIControlEventTouchUpInside];
		[self.bottomTabbar addSubview:btn_delete];
	}else if ([messageType isEqualToString:@"I"]) {
		
		self.bottomTabbar = [[UIImageView alloc]initWithFrame:CGRectMake(0, 370, 282, 54)];
		[self.bottomTabbar setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"CustomInvitationTabbar")]];
		[self.vi_main addSubview:self.bottomTabbar];
		self.bottomTabbar.userInteractionEnabled = YES;
		[self.bottomTabbar release];
		
		UIButton *btn_accept = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_accept.tag =201;
		[btn_accept addTarget:self action:@selector(bottomTabbarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn_accept setFrame:CGRectMake(23, 13, 68, 28)];
		[btn_accept setBackgroundColor:[UIColor clearColor]];
		[self.bottomTabbar addSubview:btn_accept];
		
		UIButton *btn_decline = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_decline.tag = 202;
		[btn_decline addTarget:self action:@selector(bottomTabbarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn_decline setFrame:CGRectMake(110, 13, 70, 28)];
		[btn_decline setBackgroundColor:[UIColor clearColor]];
		[self.bottomTabbar addSubview:btn_decline];
		
		UIButton *btn_ignore = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_ignore.tag = 203;
		[btn_ignore addTarget:self action:@selector(bottomTabbarBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn_ignore setFrame:CGRectMake(205, 13, 70, 28)];
		[btn_ignore setBackgroundColor:[UIColor clearColor]];
		[self.bottomTabbar addSubview:btn_ignore];
	}
}

- (void) bottomTabbarBtnClicked : (id) sender {
	UIButton *btn = (UIButton *)sender;
	[DELEGATE addLoadingView:self.vi_main];	
	
	switch (btn.tag) {
		case 201:
			self.RSVPAccepted = YES;
		[api_tyke joinKnitAccept:[self.dict_messageData objectForKey:@"txtMsgId"] responseCode:@"1"];
			break;
		case 202:
		[api_tyke joinKnitAccept:[self.dict_messageData objectForKey:@"txtMsgId"] responseCode:@"0"];
			break;
		case 203:
		[api_tyke joinKnitAccept:[self.dict_messageData objectForKey:@"txtMsgId"] responseCode:@"3"];
			break;
		default:
			break;
	}
}

- (void) replyToMessage : (id) sender {

	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	
	ComposeMailViewController *compose = [[ComposeMailViewController alloc]initWithNibName:@"ComposeMailViewController" bundle:nil];
	compose.prevContImage = currentImage;
	compose.msgSubject = [self.dict_messageData objectForKey:@"txtMsgSubject"];
	compose.replyToID = [self.dict_messageData objectForKey:@"txtFromUserTblFk"];
	compose.replyToName = [NSString stringWithFormat:@"%@ %@",[self.dict_messageData objectForKey:@"txtFromFirstName"],[self.dict_messageData objectForKey:@"txtFromLastName"]];
	[self.navigationController pushViewController:compose animated:NO];
	[compose release];
}

- (void) deleteMessage : (id) sender {

	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke deleteMessages:[self.dict_prevData objectForKey:@"txtMsgId"]];

}

- (void) segementIndexChanged : (CustomSegmentView*) sender callAPI:(BOOL)callAPI {
	
	CustomSegmentView *seg = (CustomSegmentView *) sender;

	if ([[self.dict_messageData objectForKey:@"txtMsgType"] isEqualToString:@"I"]) {
		if (callAPI) {
			if ([seg selectedIndex] == 1) {
				[DELEGATE addLoadingView:self.vi_main];
				[api_tyke joinKnitAccept:[self.dict_messageData objectForKey:@"txtMsgId"] responseCode:@"1"];
			}else if ([seg selectedIndex]== 2) {
				[DELEGATE addLoadingView:self.vi_main];
				[api_tyke joinKnitAccept:[self.dict_messageData objectForKey:@"txtMsgId"] responseCode:@"0"];
			}else if ([seg selectedIndex]== 3) {
				[DELEGATE addLoadingView:self.vi_main];
				[api_tyke joinKnitAccept:[self.dict_messageData objectForKey:@"txtMsgId"] responseCode:@"3"];
			}
		}
	}else if ([[self.dict_messageData objectForKey:@"txtMsgType"] isEqualToString:@"P"]) {
		if ([self.dict_messageData objectForKey:@"playdateID"]) {
			NSString *playdate_id = [self.dict_messageData objectForKey:@"playdateID"];
			if ([seg selectedIndex] == 1) {
				[api_tyke postRSVP:playdate_id RSVPStatus:@"YES"];
				[[seg superview] removeFromSuperview];
			}else if ([seg selectedIndex]== 2) {
				[api_tyke postRSVP:playdate_id RSVPStatus:@"NO"];
				[[seg superview] removeFromSuperview];
			}else if ([seg selectedIndex]== 3) {
				[api_tyke postRSVP:playdate_id RSVPStatus:@"MAYBE"];
				[[seg superview] removeFromSuperview];
			}
		}
	}
}


#pragma mark -
#pragma mark TableViewDelegate Methods
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		return 40;
	}else if (indexPath.row == 1) {
		return 50;
	}
	return 320;

}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
		return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	//int rowInd = [indexPath row];
	if (indexPath.row == 0) {
		NSString *userInfoCell = @"addFriendsCell";
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UILabel *lbl_cell1 = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 50, 40)];
			[lbl_cell1 setBackgroundColor:[UIColor clearColor]];
			lbl_cell1.text = @"From:";
			lbl_cell1.font = [UIFont boldSystemFontOfSize:14];
			lbl_cell1.textColor = [UIColor lightGrayColor];
			[cell.contentView addSubview:lbl_cell1];
			[lbl_cell1 release];
			
			UILabel *lbl_cell2 = [[UILabel alloc]initWithFrame:CGRectMake(78, 0, 200, 40)];
			lbl_cell2.numberOfLines = 0;
			lbl_cell2.tag = 2;
			[lbl_cell2 setBackgroundColor:[UIColor clearColor]];
			lbl_cell2.textColor =[UIColor grayColor];
			[lbl_cell2 setFont:[UIFont boldSystemFontOfSize:14]];
			[cell.contentView addSubview:lbl_cell2];
			[lbl_cell2 release];
			
		}
		
		UILabel *lbl_cell2 = (UILabel *)[cell.contentView viewWithTag:2];
		if ([self.dict_messageData objectForKey:@"txtFromFirstName"] && [self.dict_messageData objectForKey:@"txtFromLastName"]) {
			lbl_cell2.text = [NSString stringWithFormat:@"%@ %@",[self.dict_messageData objectForKey:@"txtFromFirstName"],[self.dict_messageData objectForKey:@"txtFromLastName"]];
		}
		return cell;
	}else if (indexPath.row == 1) {
		NSString *userInfoCell = @"subjectCell";
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UILabel *lbl_cell1 = [[UILabel alloc]initWithFrame:CGRectMake(30, 5, 200, 20)];
			lbl_cell1.tag = 11;
			[lbl_cell1 setBackgroundColor:[UIColor clearColor]];
			lbl_cell1.text = @"Message Subject";
			[lbl_cell1 setFont:[UIFont boldSystemFontOfSize:16]];
			lbl_cell1.textColor = [UIColor colorWithRed:0.059 green:0.204 blue:0.408 alpha:1.0];
			[cell.contentView addSubview:lbl_cell1];
			[lbl_cell1 release];
			
			UILabel *lbl_timestamp = [[UILabel alloc]initWithFrame:CGRectMake(30, 25, 200, 20)];
			[lbl_timestamp setBackgroundColor:[UIColor clearColor]];
			[lbl_timestamp setTag:12];
			[lbl_timestamp setFont:[UIFont systemFontOfSize:13]];
			[lbl_timestamp setTextColor:[UIColor grayColor]];
			[cell.contentView addSubview:lbl_timestamp];
			[lbl_timestamp release];
		}
		
		UILabel *lbl_cell1 = (UILabel *)[cell.contentView viewWithTag:11];
		UILabel *lbl_timestamp = (UILabel *)[cell.contentView viewWithTag:12];
		
		if ([self.dict_messageData objectForKey:@"txtTimestamp"]) {
//			NSArray *arr = [[self.dict_messageData objectForKey:@"txtTimestamp"] componentsSeparatedByString:@"."];
//			NSString *str = [arr objectAtIndex:0];
			NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
			[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SZ"];
//			NSDate *dt = [formatter dateFromString:str];
			NSDate *dt = [formatter dateFromString:[self.dict_messageData objectForKey:@"txtTimestamp"]];
			[formatter setDateFormat:@"h:mm a"];
			NSString *time = [formatter stringFromDate:dt];
			[formatter setDateStyle:NSDateFormatterMediumStyle];
			NSString *str1 = [formatter stringFromDate:dt];
			lbl_timestamp.text = [NSString stringWithFormat:@"%@ %@",str1,time];
			[formatter release];
		}
		
		if ([self.dict_messageData objectForKey:@"txtMsgSubject"]) {
			lbl_cell1.text = [self.dict_messageData objectForKey:@"txtMsgSubject"];
		}
		
		if ([[self.dict_messageData objectForKey:@"txtMsgType"] isEqualToString:@"M"]) {
			//lbl_cell1.text = [dict objectForKey:@"txtMsgSubject"];
		}else if ([[self.dict_messageData objectForKey:@"txtMsgType"] isEqualToString:@"I"]) {
			lbl_cell1.text =@"Knitroduction Request";
		}else if ([[self.dict_messageData objectForKey:@"txtMsgType"] isEqualToString:@"P"]) {
			//lbl_cell1.text =@"Playdate Request Sent for you";
		}
		
		return cell;
				
	}else if (indexPath.row == 2) {
		NSString *userInfoCell = @"addFriendsCell";
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UILabel *lbl_cell1 = [[UILabel alloc]initWithFrame:CGRectMake(30, 0, 200, 140)];
			lbl_cell1.tag = 21;
			lbl_cell1.numberOfLines = 0 ;
			[lbl_cell1 setBackgroundColor:[UIColor clearColor]];
			lbl_cell1.textAlignment = UITextAlignmentLeft;
			lbl_cell1.text = @"I would like to invite you for a playdate. To RSVP, simple click any of the buttons below.";
			[lbl_cell1 setFont:[UIFont systemFontOfSize:15]];
			lbl_cell1.textColor = [UIColor grayColor];
			[cell.contentView addSubview:lbl_cell1];
			[lbl_cell1 release];
		}
		
		UILabel *lbl_cell1 = (UILabel *)[cell viewWithTag:21];
		
		if ([self.dict_messageData objectForKey:@"txtMsgBody"]) {
			lbl_cell1.text = [self.dict_messageData objectForKey:@"txtMsgBody"];
		}
		
		if ([[self.dict_messageData objectForKey:@"txtMsgType"] isEqualToString:@"M"]) {
			//lbl_cell1.text = [dict objectForKey:@"txtMsgSubject"];
		}else if ([[self.dict_messageData objectForKey:@"txtMsgType"] isEqualToString:@"I"]) {
			lbl_cell1.text = @"Would like to connect with you and join the knit.";
		}else if ([[self.dict_messageData objectForKey:@"txtMsgType"] isEqualToString:@"P"]) {
			//lbl_cell1.text =@"Playdate Request Sent for you";
		}

		CGSize aSize = [lbl_cell1.text sizeWithFont:lbl_cell1.font constrainedToSize:CGSizeMake(200, 250) lineBreakMode:lbl_cell1.lineBreakMode];
		lbl_cell1.frame = CGRectMake( 30, 5, aSize.width, aSize.height);
		
//		[[cell viewWithTag:2345] removeFromSuperview];
//		CustomSegmentView *segView = [self getSegmentViewWithType:[self.dict_messageData objectForKey:@"txtMsgType"]];
//		if (segView) {
//			segView.delegate = self;
//			segView.frame = CGRectMake(52,cell.frame.origin.y+cell.frame.size.height -120 , 175, 30);
//			segView.tag = 2345;
//			[cell addSubview:segView];
//		}
		return cell;
	}
	return nil;
}

#pragma mark -
#pragma mark API CALLS
- (void) deleteMessagesResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		MessagesViewController *message = (MessagesViewController *)[[self.navigationController viewControllers] objectAtIndex:1];
		for (int i =0;i < [message.arr_data count];i++) {
			if ([[[[message arr_data] objectAtIndex:i] objectForKey:@"txtMsgId"] isEqualToString:self.msgID]) {
				[[message arr_data] removeObjectAtIndex:i];
				[self popViewController];
				break;
			}
		}
	}
}

- (void) getMessageDetailsResponse : (NSData *)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		if ([[self.dict_prevData objectForKey:@"txtMsgReadStatus"] isEqualToString:@"N"]) {
			[api_tyke updateMessageStatus:[self.dict_prevData objectForKey:@"txtMsgId"] txtReadStatus:@"R"];
		}else {
			[DELEGATE removeLoadingView:self.vi_main];
			if (![[self.dict_prevData objectForKey:@"txtMsgType"] isEqualToString:@"P"] ) {
				[self addBottomTabbarForType:[self.dict_prevData objectForKey:@"txtMsgType"]];
			}
		}
		self.dict_messageData = [response objectForKey:@"response"];
		[self.theTableView reloadData];
	}
}
- (void) updateMessageStatusResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
		[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		[self.dict_prevData setObject:@"R" forKey:@"txtMsgReadStatus"];
		if (![[self.dict_prevData objectForKey:@"txtMsgType"] isEqualToString:@"P"]) {
			[self addBottomTabbarForType:[self.dict_prevData objectForKey:@"txtMsgType"]];
		}
		[self.theTableView reloadData];
	}		
}

- (void) getJoinKnitAcceptResponse : (NSData *)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		[self popViewController];
	}
	if (self.RSVPAccepted) {
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_MESSAGE_LIST_CHANGED object:self userInfo:nil];
	}

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

- (CustomSegmentView*) getSegmentViewWithType : (NSString *)msgtype {
	
	CustomSegmentView *seg_control = nil;
	if ([msgtype isEqualToString:@"I"]) {
		NSMutableArray *arr_segments = [[NSMutableArray alloc]init];
		
		NSMutableDictionary *dict_accept = [[NSMutableDictionary alloc]init];
		[dict_accept setObject:@"seg_accept_selected.png" forKey:@"imageName"];
		[dict_accept setObject:@"" forKey:@"title"];
		[arr_segments addObject:dict_accept];
		[dict_accept release];
		
		NSMutableDictionary *dict_decline = [[NSMutableDictionary alloc]init];
		[dict_decline setObject:@"seg_decline_selected.png" forKey:@"imageName"];
		[dict_decline setObject:@"" forKey:@"title"];
		[arr_segments addObject:dict_decline];
		[dict_decline release];
		
		NSMutableDictionary *dict_ignore = [[NSMutableDictionary alloc]init];
		[dict_ignore setObject:@"seg_ignore_selected.png" forKey:@"imageName"];
		[dict_ignore setObject:@"" forKey:@"title"];
		[arr_segments addObject:dict_ignore];
		[dict_ignore release];
		
		seg_control = [[[CustomSegmentView alloc]initWithFrame:CGRectMake(52, 15, 175, 30) withSegments:[arr_segments autorelease] defaultImage:@"default_acceptRejectSeg.png" andDelegate:self] autorelease];
		[seg_control setBackgroundColor:[UIColor clearColor]];
	}else if ([msgtype isEqualToString:@"P"]) {
		NSMutableArray *arr_segments = [[NSMutableArray alloc]init];
		
		NSMutableDictionary *dict_accept = [[NSMutableDictionary alloc]init];
		[dict_accept setObject:@"seg_yesNoYesSelected.png" forKey:@"imageName"];
		[dict_accept setObject:@"" forKey:@"title"];
		[arr_segments addObject:dict_accept];
		[dict_accept release];
		
		NSMutableDictionary *dict_decline = [[NSMutableDictionary alloc]init];
		[dict_decline setObject:@"seg_yesNoNoSelected.png" forKey:@"imageName"];
		[dict_decline setObject:@"" forKey:@"title"];
		[arr_segments addObject:dict_decline];
		[dict_decline release];
		
		NSMutableDictionary *dict_ignore = [[NSMutableDictionary alloc]init];
		[dict_ignore setObject:@"seg_yesNoMaybeSelected.png" forKey:@"imageName"];
		[dict_ignore setObject:@"" forKey:@"title"];
		[arr_segments addObject:dict_ignore];
		[dict_ignore release];
		
		seg_control = [[[CustomSegmentView alloc]initWithFrame:CGRectMake(52, 15, 175, 30) withSegments:[arr_segments autorelease] defaultImage:@"seg_yesNoDeselected.png" andDelegate:self] autorelease];
		[seg_control setBackgroundColor:[UIColor clearColor]];
	}else if ([msgtype isEqualToString:@"M"]) {
	}
	

	return seg_control;
}

- (void)dealloc {
	[self.dict_prevData release];
	[self.dict_messageData release];
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}


@end
