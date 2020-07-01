//
//  AddEventViewController.m
//  TykeKnit
//
//  Created by Manish Gupta on 21/06/11.
//  Copyright 2011 Tykeknit. All rights reserved.
//

#import "AddEventViewController.h"
#import "Global.h"
#import "JSON.h"
#import "Messages.h"


@implementation AddEventViewController

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 160;

@synthesize theTableView,MessageView;
@synthesize dict_eventData, arr_eventData, api_tyke;

- (void) viewWillAppear:(BOOL)animated {
    [[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_events2 aboveSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_events1 belowSubview:[DELEGATE vi_sideView].img_back];
//	[self.view endEditing:YES];
	[self.theTableView reloadData];
	[super viewWillAppear:animated];
}

- (void) doneClicked : (id) sender {
	
	[self.view endEditing:YES];
	NSString *str_error;
	int flag = 0;
	if (![[self.dict_eventData objectForKey:@"txtEventTitle"] length]) {
		str_error = MSG_ERROR_VALID_EVENT_TITLE;
		flag = 1;
	}
	else if (![[self.dict_eventData objectForKey:@"txtEventDetail"] length]) {
		str_error = MSG_ERROR_VALID_EVENT_DETAIL;
		flag = 1;
	}
	else if ([[self.dict_eventData objectForKey:@"txtEventTitle"] length] > 50) {
		str_error = MSG_ERROR_VALID_LENGTH_EVENT_TITLE;
		flag = 1;
	}
	else if ([[self.dict_eventData objectForKey:@"txtEventLocation"] length] > 50) {
		str_error = MSG_ERROR_VALID_LENGTH_EVENT_LOCATION;
		flag = 1;
	}
	else if ([[self.dict_eventData objectForKey:@"txtEventDetail"] length] > 300) {
		str_error = MSG_ERROR_VALID_LENGTH_EVENT_DETAIL;
		flag = 1;
	}
    
	if (flag) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event" message:str_error 
													   delegate:self cancelButtonTitle:@"Ok" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
 
	if (!flag) {
		[api_tyke addEvent:[NSString stringWithFormat:@"%@",[self.dict_eventData objectForKey:@"txtEventTitle"]] txtEventDetail:[NSString stringWithFormat:@"%@",[self.dict_eventData objectForKey:@"txtEventDetail"]] txtEventLocation:[NSString stringWithFormat:@"%@",[self.dict_eventData objectForKey:@"txtEventLocation"]]];
		[DELEGATE addLoadingView:self.view];
	}
}

- (void)viewDidLoad {
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Share Event"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];
    
	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate = self;
	
	UIButton *btn_back = [DELEGATE getDefaultBarButtonWithTitle:@"Cancel"];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Submit"];
	[btn_done addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_done] autorelease];
	
	if (!self.dict_eventData) {
		self.dict_eventData = [[NSMutableDictionary alloc]init];
	}
	[super viewDidLoad];
}

-(void) backPressed:(id)sender{
    [self.dict_eventData removeAllObjects];
    for (UIViewController *vi_cont in [self.navigationController viewControllers]) {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

#pragma mark -
#pragma mark TableViewDelegate

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 2) {
		return 200;
	}
	return 44;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	int section = [indexPath section];
	if (section==0) {
		NSString *CellIdentifier = @"EventTitle";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.backgroundColor = [UIColor colorWithRed:0.9290 green:0.9490 blue:0.9610 alpha:1.0];
			
			UITextField *txt_Cell = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 240, 44.0)];
			txt_Cell.backgroundColor = [UIColor clearColor];
			txt_Cell.placeholder = @"Event Title (e.g. Story-time with Elmo)";
			txt_Cell.tag = 1;
//			txt_Cell.autocorrectionType = UITextAutocorrectionTypeNo;
			txt_Cell.autocorrectionType = UITextAutocorrectionTypeYes;
			txt_Cell.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			txt_Cell.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			[txt_Cell addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			txt_Cell.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			[txt_Cell addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			[txt_Cell setReturnKeyType:UIReturnKeyNext];
			[cell.contentView addSubview:txt_Cell];
			[txt_Cell release];
		}
		
		UITextField *txt_Cell = (UITextField *)[cell viewWithTag:1];
		if ([self.dict_eventData objectForKey:@"txtEventTitle"]) {
			txt_Cell.text = [self.dict_eventData objectForKey:@"txtEventTitle"];
		}else {
			txt_Cell.text = @"";
		}
        
		cell.tag = indexPath.section;
		return cell;
	} else if(section == 1) {
		NSString *CellIdentifier = @"EventLocation";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.backgroundColor = [UIColor colorWithRed:0.9290 green:0.9490 blue:0.9610 alpha:1.0];
			
			UITextField *txt_Cell = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, 240, 44.0)];
			txt_Cell.backgroundColor = [UIColor clearColor];
			txt_Cell.placeholder = @"Location (e.g. Dallas, TX)";
			txt_Cell.tag = 3;
			txt_Cell.autocorrectionType = UITextAutocorrectionTypeYes;
			txt_Cell.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			txt_Cell.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			[txt_Cell addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			txt_Cell.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
			[txt_Cell addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			[txt_Cell setReturnKeyType:UIReturnKeyNext];
			[cell.contentView addSubview:txt_Cell];
			[txt_Cell release];
		}
		
		UITextField *txt_Cell = (UITextField *)[cell viewWithTag:3];
		if ([self.dict_eventData objectForKey:@"txtEventLocation"]) {
			txt_Cell.text = [self.dict_eventData objectForKey:@"txtEventLocation"];
		}else {
			txt_Cell.text = @"";
		}
        
		cell.tag = indexPath.section;
		return cell;
    }else if(section==2) {
		NSString *CellIdentifier = @"EventDetail";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.backgroundColor = [UIColor colorWithRed:0.9290 green:0.9490 blue:0.9610 alpha:1.0];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
			self.MessageView = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(5, 0, 240, 200)];
//			self.MessageView.autocorrectionType = UITextAutocorrectionTypeNo;
			self.MessageView.autocorrectionType = UITextAutocorrectionTypeYes;
			[self.MessageView setDelegate:self];
			[self.MessageView setFont:[UIFont fontWithName:@"helvetica Neue" size:14]];
			[self.MessageView setTag:2];
//			[self.MessageView setTextColor:[UIColor darkGrayColor]];
            [self.MessageView setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			[self.MessageView setBackgroundColor:[UIColor clearColor]];
            self.MessageView.placeholder = @"Event Details (e.g. Smithsonian Museum, $5 per kid, every Tuesday)";
			[cell.contentView addSubview:self.MessageView];
			[self.MessageView release];
		}

        if ([self.dict_eventData objectForKey:@"txtEventDetail"]) {
			self.MessageView.text = [self.dict_eventData objectForKey:@"txtEventDetail"];
		}else {
			self.MessageView.text = @"";
		}

		cell.tag = indexPath.section;

		return cell;
	}
	return nil;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	
	NSString *value = textView.text;
	[self.dict_eventData setObject:value forKey:@"txtEventDetail"];
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationCompleted:)];
	[[[DELEGATE window] viewWithTag:255] setFrame:CGRectMake(0, 468, 320, 44)];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
//	[self.MessageView setFrame:CGRectMake(10, 0, 240, 200)];
	self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, 120);
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
	
	
	CGRect viewFrame = self.MessageView.frame;
	viewFrame.size.height -= animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
//	[self.MessageView setFrame:viewFrame];
	self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, -120);
    
	[UIView commitAnimations];
	
	UINavigationItem *nav_item = [[UINavigationItem alloc] init];
	nav_item.title = @"Event Detail";
	UINavigationBar *navBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 468, 320, 44)];
	[navBar setBarStyle:UIBarStyleBlack];
	navBar.tag = 255;
	
/*	
	UIBarButtonItem *btn_cancel = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(kbBtnCancelClicked:)];
	[nav_item setLeftBarButtonItem:btn_cancel];
	[btn_cancel release];
*/	
	UIBarButtonItem *btn_done = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(kbBtnDoneClicked:)];
	[nav_item setRightBarButtonItem:btn_done];
	[btn_done release];
	
	[navBar pushNavigationItem:nav_item animated:NO];
	[nav_item release];
	[[DELEGATE window] addSubview:navBar];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
	[navBar setFrame:CGRectMake(0, 221, 320, 44)];
	[UIView commitAnimations];
	[navBar release];
 
}

- (void) kbBtnDoneClicked : (id) sender {
	[self.MessageView resignFirstResponder];
//	[self textViewDidEndEditing:self.MessageView];
	
}

/*
- (void) kbBtnCancelClicked : (id) sender {
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
*/ 

- (void) animationCompleted : (id) sender {
    [[[DELEGATE window] viewWithTag:255] removeFromSuperview];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.view endEditing:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark API Response

- (void) addEventResponse : (NSData*)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.view];
	[DELEGATE bringSideViewToFront];
	
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thank You" message:@"Event successfully listed." 
													  delegate:self cancelButtonTitle:@"Ok" 
											 otherButtonTitles:nil];
		[alert setTag:301];
		[alert show];
		[alert release];

		[self.dict_eventData removeAllObjects];
	}
    else {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Error Adding Event." 
                                                          delegate:self cancelButtonTitle:@"Ok" 
                                                 otherButtonTitles:nil];
            [alert setTag:301];
            [alert show];
            [alert release];
    }
	
	[theTableView reloadData];
}

- (void) nextPressed : (id) sender {
	
	UITextField *txt_field = (UITextField*)sender;
	id objCell = [[txt_field superview] superview];
	if (objCell && [objCell isKindOfClass:[UITableViewCell class]]) {
		UITableViewCell *tableCell = (UITableViewCell*)objCell;
		
		UITableViewCell *nextCell;
        
        if ([tableCell.reuseIdentifier isEqualToString:@"EventTitle"]) {
            nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            if (nextCell) {
                [[nextCell viewWithTag:3] becomeFirstResponder];
            }
        } else if ([tableCell.reuseIdentifier isEqualToString:@"EventLocation"]) {
            nextCell = [self.theTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            if (nextCell) {
                [[nextCell.contentView viewWithTag:2] becomeFirstResponder];
            }
        }
	}
}

- (void) editingEnded : (id) sender {
	
	UITextField *txt_field = (UITextField*)sender;
	NSString *value = txt_field.text;
    UITableViewCell *cell = (UITableViewCell *) [[txt_field superview] superview];
    if ([value length]) {
        if ([cell.reuseIdentifier isEqualToString:@"EventTitle"]) {
            [self.dict_eventData setObject:DefaultStringValue(value) forKey:@"txtEventTitle"];
        }else if ([cell.reuseIdentifier isEqualToString:@"EventDetail"]) {
            [self.dict_eventData setObject:DefaultStringValue(value) forKey:@"txtEventDetail"];
        }else if ([cell.reuseIdentifier isEqualToString:@"EventLocation"]) {
            [self.dict_eventData setObject:DefaultStringValue(value) forKey:@"txtEventLocation"];
        }    
    }
	[self.theTableView reloadData];
	[sender resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [api_tyke cancelCurrentRequest];
    [api_tyke release];
    [super dealloc];
}


@end
