//
//  ComposeMailViewController.m
//  TykeKnit
//
//  Created by Ver on 11/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ComposeMailViewController.h"
#import "SelectFriendsViewController.h"
#import "NSDataAdditions.h"
#import "JSON.h"

@implementation ComposeMailViewController

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 160;

@synthesize theTableView,api_tyke,dict_messageData,msgTextView,replyToID,replyToName;
@synthesize msgSubject;
- (void) viewWillAppear:(BOOL)animated {
		
	[self.theTableView reloadData];
	[super viewWillAppear:animated];
}

- (void)viewDidLoad {
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Message"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	
	UIButton *btn_cancel = [DELEGATE getDefaultBarButtonWithTitle:@"Cancel"];
	btn_cancel.tag = 101;
	[btn_cancel addTarget:self action:@selector(cancelClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_cancel] autorelease];
	
	UIButton *btn_send = [DELEGATE getDefaultBarButtonWithTitle:@"Send"];
	btn_send.tag = 102;
	[btn_send addTarget:self action:@selector(sendClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_send] autorelease];
	[self.navigationItem setHidesBackButton:YES];
	animatedDistance = 0.0f;
	self.dict_messageData = [[NSMutableDictionary alloc]init];
	
	if (!api_tyke) {
		api_tyke = [[TykeKnitApi alloc]init];
		api_tyke.delegate = self;
	}
	
    [super viewDidLoad];
}

- (void) cancelClicked: (id) sender {
	[self popViewController];
}

- (void) sendClicked : (id) sender {
	
	[self.view endEditing:YES];
	BOOL Flag = 0;
	NSString *strError = nil;

	if (![[self.dict_messageData objectForKey:@"msgSubject"] length] > 0) {
		strError = @"Please Enter Subject";
		Flag = 1; 
	} else 	if (![[self.dict_messageData objectForKey:@"msgBody"] length] > 0) {
		strError = @"There is no text in the body of this message.";
		Flag = 1;
	}
	
	if (!self.replyToName) {
		if (![[[self.dict_messageData objectForKey:@"friends"] allKeys] count]) {
			strError = @"Please Select Recipient";
			Flag = 1;
		} 
	}
	
	if (Flag) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"  message:strError
													   delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}else {
		[DELEGATE addLoadingView:self.vi_main];
		if (self.replyToName && self.replyToID) {
			[api_tyke sendMessage:self.replyToID
				txtMessageSubject:[self.dict_messageData objectForKey:@"msgSubject"] 
					   txtMsgBody:[self.dict_messageData objectForKey:@"msgBody"]];
			
		}else {
			[api_tyke sendMessage:[[self.dict_messageData objectForKey:@"friends"]objectForKey:@"id"]
				txtMessageSubject:[self.dict_messageData objectForKey:@"msgSubject"] 
					   txtMsgBody:[self.dict_messageData objectForKey:@"msgBody"]];
		}
	}
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 2) {
		return 300;
	}
	return 44;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	return 3;	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	NSString *userInfoCell = @"userInfoCell";
	if (indexPath.row != 2) {
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UILabel *lbl_cell = [[UILabel alloc]initWithFrame:CGRectMake(25, 12, 70, 20)];
			[lbl_cell setBackgroundColor:[UIColor clearColor]];
			[lbl_cell setTextColor:[UIColor lightGrayColor]];
			[lbl_cell setFont:[UIFont systemFontOfSize:14]];
			[lbl_cell setTag:1];
			[cell.contentView addSubview:lbl_cell];
			[lbl_cell release];
			
			UITextField *txt_cell = [[UITextField alloc]initWithFrame:CGRectMake(100, 12, 100, 20)];
			[txt_cell setBackgroundColor:[UIColor clearColor]];
			[txt_cell setTextColor:[UIColor grayColor]];
			txt_cell.autocorrectionType = UITextAutocorrectionTypeNo;
			txt_cell.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			[txt_cell setFont:[UIFont boldSystemFontOfSize:14]];
			[txt_cell addTarget:self action:@selector(editingStart:) forControlEvents:UIControlEventEditingDidBegin];
			[txt_cell addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[txt_cell addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			[txt_cell setReturnKeyType:UIReturnKeyNext];
			[txt_cell setTag:2];
			[cell.contentView addSubview:txt_cell];
			[txt_cell release];
			
		}
		
		UILabel *lbl_cell = (UILabel *)[cell.contentView viewWithTag:1];
		UITextField *txt_cell = (UITextField *)[cell.contentView viewWithTag:2];
		txt_cell.placeholder = @"";
		[txt_cell setUserInteractionEnabled:YES];
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		switch (indexPath.row) {
			case 0:
				if (self.replyToName) {
					txt_cell.text = self.replyToName;
				}
				if ([self.dict_messageData objectForKey:@"friends"]) {
					txt_cell.text = [NSString stringWithFormat:@"%@ %@", [[self.dict_messageData objectForKey:@"friends"] objectForKey:@"firstName"], [[self.dict_messageData objectForKey:@"friends"] objectForKey:@"lastName"]];
				}
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				txt_cell.frame = CGRectMake(55, 12, 200, 20);
				[txt_cell setUserInteractionEnabled:NO];
				lbl_cell.text = @"To :";
				
				break;
			case 1:
				txt_cell.frame = CGRectMake(85, 12, 180, 20);
				if ([self.msgSubject length] > 1) {
					txt_cell.text = [NSString stringWithFormat:@"Re: %@",self.msgSubject];
					[self.dict_messageData setObject:DefaultStringValue(txt_cell.text) forKey:@"msgSubject"];
				}
//				txt_cell.placeholder = @"Re:<Subject>";
//				if (self.replyToName) {
//				txt_cell.placeholder = @"Re: nomenclature";
//				}
				lbl_cell.text = @"Subject : ";
				break;
			default:
				break;
		}
		cell.tag = indexPath.row;
	}else {
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;

			self.msgTextView = [[UITextView alloc]initWithFrame:CGRectMake(15, 12, 250, 200)];
			self.msgTextView.autocorrectionType = UITextAutocorrectionTypeNo;
			[self.msgTextView setDelegate:self];
			[self.msgTextView setFont:[UIFont systemFontOfSize:14]];
			[self.msgTextView setTag:2];
			[self.msgTextView setTextColor:[UIColor darkGrayColor]];
			[self.msgTextView setBackgroundColor:[UIColor clearColor]];
			[cell.contentView addSubview:self.msgTextView];
			[self.msgTextView release];
		}
		
		cell.tag = indexPath.row;
	}

	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == 0) {
		
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		SelectFriendsViewController *friends = [[SelectFriendsViewController alloc]initWithNibName:@"SelectFriendsViewController" bundle:nil];
		friends.dict_messageData = self.dict_messageData;
		friends.prevContImage = currentImage;
		[self.navigationController pushViewController:friends animated:NO];
		[friends release];
		
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	
	NSString *value = textView.text;
	[self.dict_messageData setObject:value forKey:@"msgBody"];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationCompleted:)];
	[[[DELEGATE window] viewWithTag:255] setFrame:CGRectMake(0, 468, 320, 44)];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[self.msgTextView setFrame:CGRectMake(15, 12, 250, 200)];
	[UIView commitAnimations];
	
	
}
- (void)textViewDidBeginEditing:(UITextView *)textView {
	
	CGRect textFieldRect = [self.theTableView convertRect:textView.bounds fromView:textView];
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
    animatedDistance+= 44.0;
	
	
	CGRect viewFrame = self.msgTextView.frame;
	viewFrame.size.height -= animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[self.msgTextView setFrame:viewFrame];
	[UIView commitAnimations];
	
	UINavigationItem *nav_item = [[UINavigationItem alloc] init];
	nav_item.title = @"Add Message";
	UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 468, 320, 44)];
	[navBar setBarStyle:UIBarStyleBlack];
	navBar.tag = 255;
	
	
	UIBarButtonItem *btn_cancel = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(btnCancelClicked:)];
	[nav_item setLeftBarButtonItem:btn_cancel];
	[btn_cancel release];
	
	UIBarButtonItem *btn_done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(btnDoneClicked:)];
	[nav_item setRightBarButtonItem:btn_done];
	[btn_done release];
	
	[navBar pushNavigationItem:nav_item animated:NO];
	[nav_item release];
	[[DELEGATE window] addSubview:navBar];
	[navBar release];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
	[navBar setFrame:CGRectMake(0, 221, 320, 44)];
	[UIView commitAnimations];
	
	
}
- (void) btnDoneClicked : (id) sender {
	[self.msgTextView resignFirstResponder];
	[self textViewDidEndEditing:self.msgTextView];
	
}
- (void) btnCancelClicked : (id) sender {
	[self.view endEditing:YES];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationCompleted:)];
	[[[DELEGATE window] viewWithTag:255] setFrame:CGRectMake(0, 468, 320, 44)];
	[self.theTableView setFrame:CGRectMake(0, 0, 280, 416)];
	[UIView commitAnimations];

}

- (void) animationCompleted : (id) sender {
		[[[DELEGATE window] viewWithTag:255] removeFromSuperview];
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
    animatedDistance += 44.0;
	
	CGRect viewFrame = self.msgTextView.frame;
	viewFrame.size.height -= animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
	[self.msgTextView setFrame:viewFrame];
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
		if ([reuseIdentifier isEqualToString:@"userInfoCell"]) {
			int currTag = tableCell.tag;
			if (currTag == 0) {
				nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
				if (nextCell) {
					[[nextCell.contentView viewWithTag:2] becomeFirstResponder];
				}
			}else if (currTag == 1) {
				nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
				if (nextCell) {
					[[nextCell.contentView viewWithTag:2] becomeFirstResponder];
				}
			}else if (currTag == 2) {
				nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
				if (nextCell) {
					[[nextCell.contentView viewWithTag:2] becomeFirstResponder];
				}
			}
		}
	}
	
}


- (void) editingEnded:(id)sender {
	UITextField *txt_field = (UITextField *)sender;
	NSString *value = txt_field.text;
	UITableViewCell *cell = (UITableViewCell *)[[txt_field superview] superview];
	if ([value length]) {
		if ([cell.reuseIdentifier isEqualToString:@"userInfoCell"]) {
			if (cell.tag==0) {
				[self.dict_messageData setObject:DefaultStringValue(value) forKey:@"ToUser"];
			}else if (cell.tag == 1) {
				[self.dict_messageData setObject:DefaultStringValue(value) forKey:@"msgSubject"];
			}else if (cell.tag == 2) {
				[self.dict_messageData setObject:DefaultStringValue(value) forKey:@"msgBody"];
			}
		}
	}
	
	CGRect viewFrame = [self.theTableView frame];
	viewFrame.origin.y += animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[self.theTableView setFrame:viewFrame];
	[UIView commitAnimations];
}

- (void) sendMessageResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {

		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success!"
													   message:@"Message sent Successfully" 
													  delegate:nil
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		[self popViewController];
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!"
													   message:@"Message Sending Failed" 
													  delegate:nil
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
	}
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
}


- (void)dealloc {
	[self.dict_messageData release];
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}


@end
