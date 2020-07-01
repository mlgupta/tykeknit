//
//  MessagesViewController.m
//  TykeKnit
//
//  Created by Ver on 07/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MessagesViewController.h"
#import "ComposeMailViewController.h"
#import "MessageDetailViewController.h"
#import "PlaydateDetailViewController.h"
#import "CustomSegmentView.h"
#import "Global.h"
#import "JSON.h"

@implementation MessagesViewController
@synthesize theTableView,api_tyke,arr_data,selectedIndexPath,swipeView,toReload,RemoveRow;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.


- (void) editClicked : (id) sender {

	if (self.navigationItem.rightBarButtonItem.customView.tag == 102) {
		UIButton *btn_delete = [DELEGATE getDefaultBarButtonWithTitle:@"Delete"];
		btn_delete.tag = 103;
		[btn_delete addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_delete] autorelease];
		
		UIButton *btn_cancel = [DELEGATE getDefaultBarButtonWithTitle:@"Cancel"];
		btn_cancel.tag = 104;
		[btn_cancel addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_cancel] autorelease];
		
	}else {
		UIButton *btn_edit = [DELEGATE getDefaultBarButtonWithTitle:@"Edit"];
		btn_edit.tag = 102;
		[btn_edit addTarget:self action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_edit] autorelease];
		
	}
	
	if (toEdit) {
		toEdit = NO;
	}else {
		toEdit = YES;
	}
	[self.theTableView reloadData];
}

- (void) deleteClicked : (id) sender {
	UIButton *btn = (UIButton *)sender;
	if (btn.tag!=104) {
		if (selectMessageForDelete > -1) {
			[DELEGATE addLoadingView:self.vi_main];
			[api_tyke deleteMessages:[[self.arr_data objectAtIndex:selectMessageForDelete] objectForKey:@"txtMsgId"]];
		}
	}
	if (self.navigationItem.rightBarButtonItem.customView.tag == 102) {
		UIButton *btn_delete = [DELEGATE getDefaultBarButtonWithTitle:@"Delete"];
		btn_delete.tag = 103;
		[btn_delete addTarget:self action:@selector(deleteClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_delete] autorelease];
	}else {
		UIButton *btn_edit = [DELEGATE getDefaultBarButtonWithTitle:@"Edit"];
		btn_edit.tag = 102;
		[btn_edit addTarget:self action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
		self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_edit] autorelease];
	}
	
	UIButton *btn_compose = [DELEGATE getDefaultBarButtonWithTitle:@"Compose"];
	btn_compose.tag = 101;
	[btn_compose addTarget:self action:@selector(ComposeClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_compose] autorelease];
	
	if (toEdit) {
		toEdit = NO;
	}else {
		toEdit = YES;
	}
	[self.theTableView reloadData];
}

- (void) editview : (id) sender {
	
	UISwipeGestureRecognizer *swipe = (UISwipeGestureRecognizer *)sender;
	self.selectedIndexPath = [self.theTableView indexPathForCell:(UITableViewCell *)[swipe view]];
	selectedMessage = self.selectedIndexPath.row;
	NSString *msgType = [[self.arr_data objectAtIndex:self.selectedIndexPath.row] objectForKey:@"txtMsgType"];
	if (self.swipeView) {
		[(UITableViewCell *)[swipe view] setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[self.swipeView removeFromSuperview];
		selectedMessage = -1;
	}		
	[self createSegmentViewWithType:msgType onCell:(UITableViewCell *)[swipe view]];
}

- (void) ComposeClicked : (id) sender {
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	
	ComposeMailViewController *compose = [[ComposeMailViewController alloc]initWithNibName:@"ComposeMailViewController" bundle:nil];
	compose.prevContImage = currentImage;
	[self.navigationController pushViewController:compose animated:NO];
	[compose release];
}

- (void) viewWillAppear:(BOOL)animated {
	
	if ([[[DELEGATE window] subviews] containsObject:[DELEGATE nav_wannaHangBar].view]) {
		[[DELEGATE nav_wannaHangBar].view removeFromSuperview];
	}
	
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_dashBoard2 aboveSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_dashboard_wannaHang belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_dashBoard1 belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_dashBoard3 belowSubview:[DELEGATE vi_sideView].img_back];
	
	if (selectedMessage != -1) {
		[self.theTableView reloadData];
	}
	
	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke getMessages];

	[super viewWillAppear:animated];
}

- (void) reloadData : (NSNotification*) notify{
	self.toReload = YES;
//	NSString *playdateid =	(NSString *)[notify object];
	[self.arr_data removeAllObjects];
	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke getMessages];
}

- (void)viewDidLoad {
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Messages"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	
	self.toReload = NO;
	UIButton *btn_compose = [DELEGATE getDefaultBarButtonWithTitle:@"Compose"];
	btn_compose.tag = 101;
	[btn_compose addTarget:self action:@selector(ComposeClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_compose] autorelease];
	
	selectedMessage = -1;
	selectMessageForDelete = -1;
	UIButton *btn_edit = [DELEGATE getDefaultBarButtonWithTitle:@"Edit"];
	btn_edit.tag = 102;
	[btn_edit addTarget:self action:@selector(editClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_edit] autorelease];
	[self.navigationItem setHidesBackButton:YES];
	
	//	self.theTableView.editing = YES;
	
	self.RemoveRow = NO;
	toEdit = NO;
	self.arr_data = [[NSMutableArray alloc]init];
	if (!api_tyke) {
		api_tyke = [[TykeKnitApi alloc]init];
		api_tyke.delegate = self;
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData:) name:NOTIFY_MESSAGE_LIST_CHANGED object:nil];
    [super viewDidLoad];
}


#pragma mark -
#pragma mark UITableViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (self.swipeView) {
		[(UITableViewCell *)[self.swipeView superview] setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		[self.swipeView removeFromSuperview];
		selectedMessage = -1;
	}
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Load the friend profile here.
	if ([self.arr_data count]) {
		selectedMessage = indexPath.row;
		
		if (toEdit) {
			UITableViewCell *cell = [self.theTableView cellForRowAtIndexPath:indexPath];
			UIButton *btnselect = (UIButton *)[cell.contentView viewWithTag:1];
			[self selectMessage:btnselect];
		}else {
			if([[[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtMsgType"] isEqualToString:@"P"]) {
				if ([[[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtMsgReadStatus"] isEqualToString:@"N"]) {
					[[self.arr_data objectAtIndex:indexPath.row] setObject:@"R" forKey:@"txtMsgReadStatus"];
					[DELEGATE addLoadingView:self.vi_main];
					[api_tyke updateMessageStatus:[[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtMsgId"] txtReadStatus:@"R"];
				}else {
					UIImage *currentImage = [self captureScreen];
					[self pushingViewController:currentImage];
					
					PlaydateDetailViewController *details = [[PlaydateDetailViewController alloc]initWithNibName:@"PlaydateDetailViewController" bundle:nil];
					details.prevContImage = currentImage;
					details.playdate_id = [[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"playdateID"];
					[self.navigationController pushViewController:details animated:NO];
					[details release];
					[self.theTableView reloadData];
				}
			}else {
				
				UIImage *currentImage = [self captureScreen];
				[self pushingViewController:currentImage];

				MessageDetailViewController *msgDetails = [[MessageDetailViewController alloc]initWithNibName:@"MessageDetailViewController" bundle:nil];
				msgDetails.prevContImage = currentImage;
				msgDetails.dict_prevData = [self.arr_data objectAtIndex:indexPath.row];
				msgDetails.msgID = [[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtMsgId"];
				msgDetails.msgType = [[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtMsgType"];
				msgDetails.msgStatus =[[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtMsgReadStatus"]; 
				[self.navigationController pushViewController:msgDetails animated:NO];
				[msgDetails release];
			}
			
		}
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

	UITableViewCell *cell;
	NSString *userInfoCell = @"userInfoCell";
	cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(editview:)];
		[cell addGestureRecognizer:gesture];
		[gesture release];
		
		UIButton *btn_select = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_select setFrame:CGRectMake(13, 22, 13, 13)];
		btn_select.tag = 1;
		[btn_select addTarget:self action:@selector(selectMessage:) forControlEvents:UIControlEventTouchUpInside];
		[cell.contentView addSubview:btn_select];
		
		UILabel *lbl_name = [[UILabel alloc]initWithFrame:CGRectMake(35, 15, 150, 20)];
		lbl_name.tag = 2;
		lbl_name.backgroundColor = [UIColor clearColor];
		//	 lbl_name.text = @"First name last name";
		lbl_name.numberOfLines = 2;
        lbl_name.lineBreakMode = UILineBreakModeTailTruncation;
		lbl_name.textColor = [UIColor darkGrayColor];
		lbl_name.textAlignment = UITextAlignmentLeft;
		lbl_name.font = [UIFont boldSystemFontOfSize:15];
		[cell.contentView addSubview:lbl_name];
		[lbl_name release];
		
		UILabel *lbl_kids = [[UILabel alloc]initWithFrame:CGRectMake(35, 20, 230, 20)];
		lbl_kids.tag = 3;
		lbl_kids.backgroundColor = [UIColor clearColor];
		lbl_kids.numberOfLines = 0;
//		lbl_kids.text = @"kids | kids | kids | kids | kids | kids";
		lbl_kids.textAlignment = UITextAlignmentLeft;
		lbl_kids.textColor = [UIColor lightGrayColor];
		lbl_kids.font = [UIFont systemFontOfSize:12];
		[cell.contentView addSubview:lbl_kids];
		[lbl_kids release];
		
		UILabel *lbl_notification_type = [[UILabel alloc] initWithFrame:CGRectMake(35, 35, 30,20)];
		lbl_notification_type.tag = 4;
		lbl_notification_type.text = @"Knitroduction";
		lbl_notification_type.backgroundColor = [UIColor clearColor];
		lbl_notification_type.textColor = [UIColor blackColor];
		lbl_notification_type.numberOfLines = 2;
		lbl_notification_type.font = [UIFont boldSystemFontOfSize:11];
		[cell.contentView addSubview:lbl_notification_type];
		[lbl_notification_type release];
		
		UILabel *lbl_notification = [[UILabel alloc] initWithFrame:CGRectMake(35, 35, 230,20)];
		lbl_notification.tag = 5;
		lbl_notification.backgroundColor = [UIColor clearColor];
		lbl_notification.textColor = [UIColor blackColor];
		lbl_notification.numberOfLines = 2;
		lbl_notification.textColor = [UIColor lightGrayColor];
		lbl_notification.font = [UIFont boldSystemFontOfSize:11];
		[cell.contentView addSubview:lbl_notification];
		[lbl_notification release];
		
		UILabel *lbl_dateTime =  [[UILabel alloc] initWithFrame:CGRectMake(175, 5, 90,20)];
		lbl_dateTime.tag = 6;
		lbl_dateTime.backgroundColor = [UIColor clearColor];
		lbl_dateTime.textAlignment = UITextAlignmentRight;
		lbl_dateTime.numberOfLines = 0;
		lbl_dateTime.textColor = [UIColor colorWithRed:0.380 green:0.670 blue:0.925 alpha:1];
		lbl_dateTime.font = [UIFont boldSystemFontOfSize:11];
		[cell.contentView addSubview:lbl_dateTime];
		[lbl_dateTime release];
	}
	
	UIButton *btn_select = (UIButton *)[cell.contentView viewWithTag:1];
	UILabel *lbl_name = (UILabel *)[cell.contentView viewWithTag:2];
	UILabel *lbl_kids = (UILabel *)[cell.contentView viewWithTag:3];
	UILabel *lbl_notification_type = (UILabel *)[cell.contentView viewWithTag:4];
	UILabel *lbl_notification = (UILabel *)[cell.contentView viewWithTag:5];
	UILabel *lbl_dateTime =  (UILabel *)[cell.contentView viewWithTag:6];
	
	if ([self.arr_data count] == 0) {
		cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.textAlignment = UITextAlignmentCenter;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = @"  You do not have any messages";
		lbl_name.text = @"";
		lbl_dateTime.text = @"";
		lbl_notification.text = @"";
		lbl_notification_type.text = @"";
		lbl_kids.text = @"";
	}else {
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = @"";
		NSMutableDictionary *dict = [self.arr_data objectAtIndex:indexPath.row];
		
		if (toEdit) {
			if (selectMessageForDelete == indexPath.row) {
				[btn_select setFrame:CGRectMake(13, 22, 20, 20)];
				[btn_select setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_selectedTyke")] forState:UIControlStateNormal];
				[btn_select setSelected:YES];
			}else {
				[btn_select setFrame:CGRectMake(13, 22, 20, 20)];
				[btn_select setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_deselectTyke")] forState:UIControlStateNormal];
				[btn_select setSelected:NO];
			}
			
		}else {
			[btn_select setFrame:CGRectMake(13, 22, 13, 13)];
			if (selectedMessage != -1) {
				NSDictionary *dict1 = [self.arr_data objectAtIndex:selectedMessage];
				if ([[dict1 objectForKey:@"txtMsgReadStatus"] isEqualToString:@"N"]) {
					[btn_select setBackgroundImage:nil forState:UIControlStateNormal];
				}else {
					[btn_select setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_selectMessages")] forState:UIControlStateNormal];
				}
			}
			if ([[dict objectForKey:@"txtMsgReadStatus"] isEqualToString:@"N"]) {
				[btn_select setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_selectMessages")] forState:UIControlStateNormal];
			}else {
				[btn_select setBackgroundImage:nil forState:UIControlStateNormal];
			}
		}
		
		if ([dict objectForKey:@"txtFromFirstName"] && [dict objectForKey:@"txtFromLastName"]) {
			lbl_name.text = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"txtFromFirstName"],[dict objectForKey:@"txtFromLastName"]];
		}
		
		if ([dict objectForKey:@"txtTimestamp"]) {
			lbl_dateTime.text = [self dateFormatter:indexPath];
//			lbl_dateTime.text = @"23 hours ago";
		}
		
		if ([[dict objectForKey:@"txtMsgType"] isEqualToString:@"M"]) {
			lbl_notification_type.text = @"";
			lbl_notification.text = [dict objectForKey:@"txtMsgSubject"];
		}else if ([[dict objectForKey:@"txtMsgType"] isEqualToString:@"I"]) {
			lbl_notification_type.text = @"Knitroduction";
			lbl_notification.text =@" sent to you";
		}else if ([[dict objectForKey:@"txtMsgType"] isEqualToString:@"P"]) {
			lbl_notification_type.text = @"Playdate Request";
			lbl_notification.text =@" Sent for you";
		}
		cell.tag = indexPath.row+1;
		if ([self.arr_data count] == 0) {
			self.navigationController.navigationItem.rightBarButtonItem.enabled = NO;
		}
		int xforData = 0;
		if (toEdit) {
			cell.accessoryType = UITableViewCellAccessoryNone;

			xforData = 45;
			lbl_dateTime.frame = CGRectMake(175, 5, 90, 20);
		}else {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			lbl_dateTime.frame = CGRectMake(165, 5, 90, 20);
			xforData = 35;
		}

		
		CGSize size = [lbl_name.text sizeWithFont:lbl_name.font constrainedToSize:CGSizeMake(135, 42.0) lineBreakMode:UILineBreakModeWordWrap];
		lbl_name.frame = CGRectMake(xforData, 5, size.width, size.height);

//		size = [lbl_dateTime.text sizeWithFont:lbl_dateTime.font constrainedToSize:CGSizeMake(100, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
//		lbl_dateTime.frame = CGRectMake(xforData+lbl_name.frame.size.width+30, 15, size.width, size.height);
		size = [lbl_notification_type.text sizeWithFont:lbl_notification_type.font constrainedToSize:CGSizeMake(200, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		lbl_notification_type.frame = CGRectMake(xforData, lbl_name.frame.size.height + lbl_name.frame.origin.y, size.width, size.height);
		size = [lbl_notification.text sizeWithFont:lbl_notification.font constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
		lbl_notification.frame = CGRectMake(xforData+lbl_notification_type.frame.size.width+1, lbl_name.frame.size.height + lbl_name.frame.origin.y, size.width, size.height);
		
	}
	
	return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 60;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
		int RET = 1;
	if ([self.arr_data count]) {
		RET = [self.arr_data count];
	}
	
	return RET;
}

#pragma mark -
#pragma mark API Response

- (void) updateMessageStatusResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		
		PlaydateDetailViewController *details = [[PlaydateDetailViewController alloc]initWithNibName:@"PlaydateDetailViewController" bundle:nil];
		details.prevContImage = currentImage;
		details.playdate_id = [[self.arr_data objectAtIndex:selectedMessage] objectForKey:@"playdateID"];
		[self.navigationController pushViewController:details animated:NO];
		[details release];
		[self.theTableView reloadData];
	}		
}

- (void) deleteMessagesResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		[self.arr_data removeObjectAtIndex:selectMessageForDelete];
		[self.theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
	}
	selectMessageForDelete = -1;	
}

- (void) getMessagesResponse : (NSData *)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		self.arr_data = [[response objectForKey:@"response"] objectForKey:@"InvitationsAndMessages"];
	}
	
	if (![self.arr_data count]) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}else {
		self.navigationItem.rightBarButtonItem.enabled = YES;
		self.navigationItem.leftBarButtonItem.enabled = YES;
	}
	
	if (self.toReload) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Playdate RSVP Changed" object:self userInfo:nil];
		self.toReload = NO;
	}
	[self.theTableView reloadData];
}

- (void) delWallMsgResp : (NSData*)data{
	NSDictionary *response = [[data stringValue] JSONValue];
	
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		[self.arr_data removeObjectAtIndex:self.selectedIndexPath.row];
		[self.theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
	}
}

- (void) getMessageDetailsResponse: (NSData *)data {
//	NSDictionary *response = [[data stringValue] JSONValue];
}


- (void) getInvitationsResponse : (NSData *)data {
//	NSDictionary *response = [[data stringValue] JSONValue];
}

- (void) postRSVPResponse : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		if (self.RemoveRow) {
			self.RemoveRow =NO;
			[self.arr_data removeObjectAtIndex:self.selectedIndexPath.row];
			[self.theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
		}else {
			[self.theTableView reloadData];
		}
	}		
}


- (void) getJoinKnitAcceptResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		if (self.RemoveRow) {
			self.RemoveRow =NO;
			[self.arr_data removeObjectAtIndex:self.selectedIndexPath.row];
			[self.theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationRight];
		}else {
			[self.theTableView reloadData];
		}
	}else {
		UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
														   message:[[response objectForKey:@"response"] objectForKey:@"reasonStr"]// MSG_ERROR_VALID_REGISTER4
														  delegate:nil 
												 cancelButtonTitle:@"Ok" 
												 otherButtonTitles:nil];
		[objAlert show];
		[objAlert release];
		
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
#pragma mark UITableView Components

- (void) segementIndexChanged : (CustomSegmentView*) sender callAPI:(BOOL)callAPI {
	CustomSegmentView *seg = (CustomSegmentView *) sender;
	UITableViewCell *cell = (UITableViewCell *)[[seg superview] superview];
	NSIndexPath *ind = [self.theTableView indexPathForCell:cell];
		[DELEGATE addLoadingView:self.vi_main];
	if ([[[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtMsgType"] isEqualToString:@"I"]) {
		if ([seg selectedIndex] == 1) {
//			NSLog(@"Accept");
			[api_tyke joinKnitAccept:[[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtMsgId"] responseCode:@"1"];
			[[seg superview] removeFromSuperview];
		}else if ([seg selectedIndex]== 2) {
			[api_tyke joinKnitAccept:[[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtMsgId"] responseCode:@"0"];
			[[seg superview] removeFromSuperview];
		}else if ([seg selectedIndex]== 3) {
			[api_tyke joinKnitAccept:[[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtMsgId"] responseCode:@"3"];
			[[seg superview] removeFromSuperview];
		}
	}else if ([[[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtMsgType"] isEqualToString:@"P"]) {
		if ([[self.arr_data objectAtIndex:ind.row] objectForKey:@"playdateID"]) {
			NSString *playdate_id = [[self.arr_data objectAtIndex:ind.row] objectForKey:@"playdateID"];
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
- (void) selectMessage: (id) sender {
	
	UIButton *btn_selectChild = (UIButton *) sender;
	UITableViewCell *cell = (UITableViewCell *)[[btn_selectChild superview] superview];
	if (btn_selectChild.selected) {
		if (selectMessageForDelete >= 0) {
			selectMessageForDelete = -1;
		}
		[btn_selectChild setBackgroundImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];
		btn_selectChild.selected = NO;
	}else {
		selectMessageForDelete = cell.tag-1;
		[btn_selectChild setBackgroundImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_selectedTyke.png")] forState:UIControlStateNormal];
		btn_selectChild.selected = YES;		
	}
	
	[self.theTableView reloadData];
}

- (void) createSegmentViewWithType : (NSString *)msgtype onCell:(UITableViewCell *)cell {
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	self.swipeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
	self.swipeView.backgroundColor = [UIColor clearColor];
	self.swipeView.alpha = 1.0;
	[cell addSubview:self.swipeView];
	[self.swipeView release];
	
	UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
	backView.alpha = 0.75;
	[backView setBackgroundColor:[UIColor blackColor]];
	[self.swipeView addSubview:backView];
	[backView release];
	
	if ([msgtype isEqualToString:@"I"]) {
		
		UIButton *btn_accept = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_accept setFrame:CGRectMake(20, 15, 70, 25)];
		btn_accept.tag = 101;
		[btn_accept setTitle:@"Accept" forState:UIControlStateNormal];
		btn_accept.titleLabel.font = [UIFont boldSystemFontOfSize:12];
		[btn_accept addTarget:self action:@selector(swipeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//		[btn_accept setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_commonBlueDashboard")] forState:UIControlStateNormal];
		[btn_accept setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"customBtn_dashboard")] forState:UIControlStateNormal];
		[self.swipeView addSubview:btn_accept];
		
		UIButton *btn_decline = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_decline.tag = 102;
		[btn_decline setTitle:@"Decline" forState:UIControlStateNormal];
		btn_decline.titleLabel.font = [UIFont boldSystemFontOfSize:12];
		[btn_decline setFrame:CGRectMake(110, 15, 70, 25)];
		[btn_decline addTarget:self action:@selector(swipeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn_decline setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"customBtn_dashboard")] forState:UIControlStateNormal];
		[self.swipeView addSubview:btn_decline];

		UIButton *btn_ignore = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_ignore.tag = 103;
		[btn_ignore setTitle:@"Ignore" forState:UIControlStateNormal];
		btn_ignore.titleLabel.font = [UIFont boldSystemFontOfSize:12];
		[btn_ignore setFrame:CGRectMake(200, 15, 70, 25)];
		[btn_ignore addTarget:self action:@selector(swipeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn_ignore setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"customBtn_dashboard")] forState:UIControlStateNormal];
		[self.swipeView addSubview:btn_ignore];
		
	}else if ([msgtype isEqualToString:@"P"]) {
		
		UIButton *btn_Yes = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_Yes setFrame:CGRectMake(20, 15, 70, 25)];
		btn_Yes.tag = 201;
		[btn_Yes setTitle:@"Yes" forState:UIControlStateNormal];
		btn_Yes.titleLabel.font = [UIFont boldSystemFontOfSize:12];
		[btn_Yes addTarget:self action:@selector(swipeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//		[btn_Yes setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_commonBlueDashboard")] forState:UIControlStateNormal];
		[btn_Yes setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"customBtn_dashboard")] forState:UIControlStateNormal];
		[self.swipeView addSubview:btn_Yes];
		
		UIButton *btn_No = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_No.tag = 202;
		[btn_No setTitle:@"No" forState:UIControlStateNormal];
		btn_No.titleLabel.font = [UIFont boldSystemFontOfSize:12];
		[btn_No setFrame:CGRectMake(110, 15, 70, 25)];
		[btn_No addTarget:self action:@selector(swipeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn_No setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"customBtn_dashboard")] forState:UIControlStateNormal];
		[self.swipeView addSubview:btn_No];
		
		UIButton *btn_MayBe = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_MayBe.tag = 203;
		[btn_MayBe setTitle:@"Maybe" forState:UIControlStateNormal];
		btn_MayBe.titleLabel.font = [UIFont boldSystemFontOfSize:12];
		[btn_MayBe setFrame:CGRectMake(200, 15, 70, 25)];
		[btn_MayBe addTarget:self action:@selector(swipeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn_MayBe setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"customBtn_dashboard")] forState:UIControlStateNormal];
		[self.swipeView addSubview:btn_MayBe];
		
	}else if ([msgtype isEqualToString:@"M"]) {
		
		UIButton *btn_rply = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_rply setFrame:CGRectMake(50, 20, 70, 25)];
		[btn_rply setTitle:@"Reply" forState:UIControlStateNormal];
		btn_rply.titleLabel.font = [UIFont boldSystemFontOfSize:12];
		[btn_rply addTarget:self action:@selector(replyToMessage:) forControlEvents:UIControlEventTouchUpInside];
		[btn_rply setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_commonBlueDashboard")] forState:UIControlStateNormal];
		[self.swipeView addSubview:btn_rply];
		
		UIButton *btn_delete = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_delete setTitle:@"Delete" forState:UIControlStateNormal];
		btn_delete.titleLabel.font = [UIFont boldSystemFontOfSize:12];
		[btn_delete setFrame:CGRectMake(150, 20, 70, 25)];
		[btn_delete addTarget:self action:@selector(deleteMessage:) forControlEvents:UIControlEventTouchUpInside];
		[btn_delete setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_commonBlueDashboard")] forState:UIControlStateNormal];
		[self.swipeView addSubview:btn_delete];
	}
}


- (void) swipeButtonClicked : (id) sender {
	
	UIButton *btn = (UIButton *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[btn superview] superview];
	[[btn superview] removeFromSuperview];
	NSIndexPath *ind = [self.theTableView indexPathForCell:cell];
//	NSLog(@"row :%d",ind.row);
	
	NSString *playdate_id = @"";
	if ([[self.arr_data objectAtIndex:ind.row] objectForKey:@"playdateID"]) {
		playdate_id = [[self.arr_data objectAtIndex:ind.row] objectForKey:@"playdateID"];
	}
	[DELEGATE addLoadingView:self.vi_main];
	switch (btn.tag) {
		case 101:
			[api_tyke joinKnitAccept:[[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtMsgId"] responseCode:@"1"];			
			self.RemoveRow = YES;
			break;
		case 102:
			[api_tyke joinKnitAccept:[[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtMsgId"] responseCode:@"0"];
			break;
		case 103:
			[api_tyke joinKnitAccept:[[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtMsgId"] responseCode:@"3"];
			break;
		case 201:
			self.RemoveRow = YES;
			[api_tyke postRSVP:playdate_id RSVPStatus:@"YES"];			
			break;
		case 202:
			[api_tyke postRSVP:playdate_id RSVPStatus:@"NO"];			
			break;
		case 203:
			[api_tyke postRSVP:playdate_id RSVPStatus:@"MAYBE"];			
			break;
		default:
			break;
	}
	 
}

- (void) replyToMessage : (id) sender {
	
	UIButton *btn = (UIButton *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[btn superview] superview];
	NSIndexPath *ind = [self.theTableView indexPathForCell:cell];
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	[[btn superview] removeFromSuperview];
	
	ComposeMailViewController *compose = [[ComposeMailViewController alloc]initWithNibName:@"ComposeMailViewController" bundle:nil];
	compose.prevContImage = currentImage;
	compose.replyToID = [[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtFromUserTblFk"];
	compose.msgSubject = [[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtMsgSubject"];
	compose.replyToName = [NSString stringWithFormat:@"%@ %@",[[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtFromFirstName"],[[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtFromLastName"]];
	[self.navigationController pushViewController:compose animated:NO];
	[compose release];
	
	
}

- (void) deleteMessage : (id) sender {
	
	UIButton *btn = (UIButton *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[btn superview] superview];
	NSIndexPath *ind = [self.theTableView indexPathForCell:cell];
	[[btn superview] removeFromSuperview];	
	if ([[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtMsgId"]) {
		[DELEGATE addLoadingView:self.vi_main];
		selectMessageForDelete = ind.row;
		[api_tyke deleteMessages:[[self.arr_data objectAtIndex:ind.row] objectForKey:@"txtMsgId"]];
	}
//	NSLog(@"delete");
}
- (NSString *) dateFormatter:(NSIndexPath *) indexPath{

	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SZ"];
	
	NSUInteger desiredComponents = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit 
	| NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	
//	NSArray *arr = [[[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtTimestamp"] componentsSeparatedByString:@"."];
//	NSString *strTimeStamp = [arr objectAtIndex:0];
//	NSDate *date =[formatter dateFromString:strTimeStamp];
	NSDate *date =[formatter dateFromString:[[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtTimestamp"]];
	NSDateComponents *elapsedTimeUnits = [[NSCalendar currentCalendar] components: desiredComponents
																		 fromDate: date
																		   toDate: [NSDate date]
																		  options:0];
	// format to be used to generate string to display
	NSString *scannedFormat = @"%d %@ ago";
	NSInteger number = 0;
	NSString *unit;
	
	if ([elapsedTimeUnits year] > 0) {
		number = [elapsedTimeUnits year];
		unit = [NSString stringWithFormat:@"year"];
	}
	else if ([elapsedTimeUnits month] > 0) {
		number = [elapsedTimeUnits month];
		unit = [NSString stringWithFormat:@"month"];
	}
	else if ([elapsedTimeUnits week] > 0) {
		number = [elapsedTimeUnits week];
		unit = [NSString stringWithFormat:@"week"];
	}
	else if ([elapsedTimeUnits day] > 0) {
		number = [elapsedTimeUnits day];
		unit = [NSString stringWithFormat:@"day"];
	}
	else if ([elapsedTimeUnits hour] > 0) {
		number = [elapsedTimeUnits hour];
		unit = [NSString stringWithFormat:@"hour"];
	}
	else if ([elapsedTimeUnits minute] > 0) {
		number = [elapsedTimeUnits minute];
		unit = [NSString stringWithFormat:@"minute"];
	}
	else if ([elapsedTimeUnits second] > 0) {
		number = [elapsedTimeUnits second];
		unit = [NSString stringWithFormat:@"second"];
	}
	// check if unit number is greater then append s at the end
	if (number > 1) {
		unit = [NSString stringWithFormat:@"%@s", unit];
	}
	// resultant string required
	NSString *scannedString = [NSString stringWithFormat:scannedFormat, number, unit] ;
	
	[formatter release];
	return scannedString;
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
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFY_MESSAGE_LIST_CHANGED object:nil];
	[self.arr_data release];
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}


@end

