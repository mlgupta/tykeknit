//
//  WannaHangViewController.m
//  TykeKnit
//
//  Created by Ver on 28/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#import "Global.h"
#import "WannaHangViewController.h"
#import "BaseViewController.h"
#import "Messages.h"

@implementation WannaHangViewController

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 160;

@synthesize api_Tyke,arr_Data,theTableView,arr_updatedData,dict_msgData,MessageView;

- (void) updateWannaHangStatusResponse : (NSData*) data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:nil];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		
		NSMutableDictionary *dict_userDetails = [DELEGATE getUserDetails];
		if ([[dict_userDetails allKeys] count]) {
			NSMutableArray *arr_kids = [dict_userDetails objectForKey:@"Kids"];
			for (NSMutableDictionary *dict1 in arr_kids) {
				for (NSDictionary *dict2 in self.arr_updatedData) {
					if ([[dict1 objectForKey:@"id"] isEqualToString:[dict2 objectForKey:@"Cid"]]) {
						if ([[dict2 objectForKey:@"WannaHang"] isEqualToString:@"0"]) {
							[dict1 setObject:@"f" forKey:@"status"];
						}else if ([[dict2 objectForKey:@"WannaHang"] isEqualToString:@"1"]) {
							[dict1 setObject:@"t" forKey:@"status"];
						}
					}
				}
			}
			[dict_userDetails writeToFile:[DOC_DIR stringByAppendingPathComponent:@"userDetails.plist"] atomically:NO];
		}
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Wanna Hang!" message:@"Your status has been updated." 
													  delegate:self cancelButtonTitle:@"Ok" 
											 otherButtonTitles:nil];
		[alert setTag:301];
		[alert show];
		[alert release];
		 
		[self.arr_updatedData removeAllObjects];
        [self.dict_msgData removeAllObjects];
        [self.theTableView reloadData];
//		[self popWannaHang];
	}
	
}
- (void) getWannaHangStatusResponse : (NSData*) data {

	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:nil];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		self.arr_Data = [[response objectForKey:@"response"] objectForKey:@"Kids"];
	}
	[self.theTableView reloadData];

}
- (void) getKidsResponse : (NSData*) data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	//NSLog(@"getKidsResponse : %@",response);
	[DELEGATE removeLoadingView:self.vi_main];
	self.arr_Data = [[response objectForKey:@"response"] objectForKey:@"kids"];
	if ([self.arr_Data count]) {
		[self.theTableView reloadData];
		[DELEGATE setArr_kidsList:self.arr_Data];
//        [self.theTableView reloadData];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!"
													   message:@"You dont have any kids registered" 
													  delegate:@"self"
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	} 
	
}

- (void) noNetworkConnection {
	
}

- (void) failWithError : (NSError*) error {
	
}

- (void) requestCanceled {
	
}

- (void) viewWillAppear:(BOOL)animated {
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_wannaHang aboveSubview:[DELEGATE vi_sideView].img_back];
    [[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_home belowSubview:[DELEGATE vi_sideView].img_back];
    [[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_playDateSearch belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_playDate_send belowSubview:[DELEGATE vi_sideView].img_back];

	[super viewWillAppear:animated];
    
}


- (void) viewDidLoad {
	[self.navigationItem setHidesBackButton:YES];
	UIImageView *img_Background = [[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"wannaHang_Background")]];
	img_Background.contentMode = UIViewContentModeScaleToFill;
	[img_Background setFrame:CGRectMake(0, 0, 280, 415)];
	[self.view addSubview:img_Background];
	[img_Background release];
	
	
	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Submit"];
	[btn_done addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
	[self.navigationItem setTitleView:[DELEGATE getTykeTitleViewWithTitle:@"Wanna Hang"]];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_done] autorelease];
	
//	UILabel *lbl_info = [[UILabel alloc]initWithFrame:CGRectMake(30, 60, 240, 100)];
	UILabel *lbl_info = [[UILabel alloc]initWithFrame:CGRectMake(30, 30, 240, 110)];
	lbl_info.text = @"No time to plan ahead? Ready to hang out right now? Just turn on 'Wanna Hang' - your friends will know.";
	lbl_info.numberOfLines = 0;
	[lbl_info setShadowColor:[UIColor whiteColor]];
	[lbl_info setLineBreakMode:UILineBreakModeWordWrap];
	[lbl_info setShadowOffset:CGSizeMake(0, 1)];
	[lbl_info setFont:[UIFont systemFontOfSize:13]];
	[lbl_info setBackgroundColor:[UIColor clearColor]];
	[lbl_info setTextColor:blueTextColor];
	[self.vi_main addSubview:lbl_info];
	[lbl_info release];
	
	
//	theTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 150, 240, 157) style:UITableViewStyleGrouped];
	theTableView = [[UITableView alloc]initWithFrame:CGRectMake(20, 110, 240, 420) style:UITableViewStyleGrouped];
	theTableView.delegate = self;
	theTableView.dataSource = self;
	theTableView.backgroundColor = [UIColor clearColor];
	[self.vi_main addSubview:theTableView];
	[theTableView release];
	
	api_Tyke = [[TykeKnitApi alloc]init];
	api_Tyke.delegate = self;
	
	self.view.backgroundColor = [UIColor clearColor];
/*    
	self.arr_Data = [DELEGATE arr_kidsList];
	if (![self.arr_Data count]) {
		[DELEGATE addLoadingView:self.view];
		[api_Tyke getKidList];
	}
*/
    
    if (!self.dict_msgData) {
		self.dict_msgData = [[NSMutableDictionary alloc]init];
	}

    [DELEGATE addLoadingView:self.vi_main];
    [api_Tyke getKidList];

    [self.view setBackgroundColor:[UIColor blackColor]];
	[self.theTableView setBackgroundColor:[UIColor clearColor]];


	[super viewDidLoad];
}
- (void) donePressed : (id) sender {
    NSString *str_error;
	int flag = 0;

	if ([self.arr_updatedData count]) {
        if ([[self.dict_msgData objectForKey:@"txtMessage"] length] > 300) {
            str_error = MSG_ERROR_VALID_WANNA_HANG;
            flag = 1;
        }
        
        if (flag) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Event" message:str_error 
                                                           delegate:self cancelButtonTitle:@"Ok" 
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        else {
            NSMutableDictionary *dictToSend = [[NSMutableDictionary alloc]init];
            [dictToSend setObject:self.arr_updatedData forKey:@"KidsStatus"];
            NSString *txtWannaHangStatus = [dictToSend JSONRepresentation];
            [DELEGATE addLoadingView:self.view];
            [dictToSend release];
            [api_Tyke updateWannaHangStatus:txtWannaHangStatus txtMessage:[NSString stringWithFormat:@"%@",[self.dict_msgData objectForKey:@"txtMessage"]]];
        }
	}
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [self.arr_Data count];
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 42;
    }
    else {
        return 80;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *view_ForHeader = [[[UIView alloc]initWithFrame:CGRectMake(0,0,0,0)] autorelease];
	
	UILabel *headerForSection = [[UILabel alloc]initWithFrame:CGRectMake(12, 0, 100, 17)];
	[headerForSection setBackgroundColor:[UIColor clearColor]];
	headerForSection.font = [UIFont boldSystemFontOfSize:15];
	headerForSection.textColor = [UIColor darkGrayColor];
	[view_ForHeader addSubview:headerForSection];
	[headerForSection release];
	
	return view_ForHeader;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 20.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	int section = [indexPath section];
    if (section == 0) {
        UITableViewCell *cell=nil;
        NSString *tykeInfoCell = @"tykeInfoCell";
        cell = [tableView dequeueReusableCellWithIdentifier:tykeInfoCell];
        
		if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:tykeInfoCell] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel *lbl_KidName = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 100, 34)];
            lbl_KidName.tag = 20;
            lbl_KidName.backgroundColor = [UIColor clearColor];
			lbl_KidName.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
            lbl_KidName.font = [UIFont boldSystemFontOfSize:16];
            [cell.contentView addSubview:lbl_KidName];
            [lbl_KidName release];
            
            UISwitch *switch_Cell = [[UISwitch alloc]initWithFrame:CGRectMake(120, 7, 50, 1)];
            [switch_Cell addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            [switch_Cell setOn:YES];
            switch_Cell.tag = 21;
            [cell.contentView addSubview:switch_Cell];
            [switch_Cell release];
        }
        
        UILabel*lbl_KidName = (UILabel *)[cell viewWithTag:20];
        UISwitch *switch_Cell = (UISwitch *)[cell viewWithTag:21];
        
        lbl_KidName.text = [[self.arr_Data objectAtIndex:indexPath.row] objectForKey:@"fname"];
		if ([[[self.arr_Data objectAtIndex:indexPath.row] objectForKey:@"WannaHang"] isEqualToString:@"t"]) {
			switch_Cell.on = YES;
		}else {
			switch_Cell.on = NO;
		}
        
        return cell;
    }
    else {
        NSString *CellIdentifier = @"Message";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
//			cell.backgroundColor = [UIColor colorWithRed:0.9290 green:0.9490 blue:0.9610 alpha:1.0];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			self.MessageView = [[UIPlaceHolderTextView alloc]initWithFrame:CGRectMake(10, 0, 210, 120)];
			self.MessageView.autocorrectionType = UITextAutocorrectionTypeYes;
			[self.MessageView setDelegate:self];
			self.MessageView.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			self.MessageView.textColor =[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			[self.MessageView setBackgroundColor:[UIColor clearColor]];
			[self.MessageView setPlaceholder:@"Include a message for your friends. (Example - Planning to go to Lyons Park. Join us.)"];
			[self.MessageView setTag:51];
			[cell.contentView addSubview:self.MessageView];
			[self.MessageView release];
		}
		
        if ([self.dict_msgData objectForKey:@"txtMessage"]) {
			self.MessageView.text = [self.dict_msgData objectForKey:@"txtMessage"];
		}else {
			self.MessageView.text = @"";
		}
        
		cell.tag = indexPath.section;

		return cell;
    }
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.view endEditing:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}
*/
- (void) switchChanged : (id) sender {
	UISwitch *swich = (UISwitch *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[swich superview] superview];
	NSMutableDictionary *dict = [self.arr_Data objectAtIndex:[self.theTableView indexPathForCell:cell].row];		

	BOOL ContainsCID = NO;
	NSMutableDictionary *dict_updatedData = nil;
	if (!self.arr_updatedData) {
		self.arr_updatedData = [[NSMutableArray alloc]init];
		dict_updatedData = [[NSMutableDictionary alloc]init];
	}else {
		for (NSMutableDictionary *dict_data in self.arr_updatedData) {
			if ([[dict_data objectForKey:@"Cid"] isEqualToString:[dict objectForKey:@"Cid"]]) {
				dict_updatedData = dict_data;
				ContainsCID = YES;
			}
		}
		if (!ContainsCID) {
			dict_updatedData = [[NSMutableDictionary alloc]init];
		}
	}
	if ([swich isOn]) {
		[dict_updatedData setObject:@"1" forKey:@"WannaHang"];
		[dict setObject:@"t" forKey:@"WannaHang"];
	}else {
		[dict_updatedData setObject:@"0" forKey:@"WannaHang"];
		[dict setObject:@"f" forKey:@"WannaHang"];
	}
	[dict_updatedData setObject:[dict objectForKey:@"ChildTblPk"] forKey:@"Cid"];
	if (!ContainsCID) {
		[self.arr_updatedData addObject:dict_updatedData];
		[dict_updatedData release];
	}
}

#pragma mark -
#pragma mark MessageView Methods
- (void)textViewDidEndEditing:(UITextView *)textView {
	
	NSString *value = textView.text;
	[self.dict_msgData setObject:value forKey:@"txtMessage"];
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationCompleted:)];
	[[[DELEGATE window] viewWithTag:255] setFrame:CGRectMake(0, 468, 320, 44)];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    //	[self.MessageView setFrame:CGRectMake(10, 0, 240, 200)];
    int ht = (78 + [self.arr_Data count]*42)/2;
	self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, ht);
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
    //	self.MessageView.transform = CGAffineTransformTranslate(self.MessageView.transform, 10, -85);
    int ht = (78 + [self.arr_Data count]*42);
	self.view.transform = CGAffineTransformTranslate(self.view.transform, 0, -ht);
    
	[UIView commitAnimations];
	
	UINavigationItem *nav_item = [[UINavigationItem alloc] init];
	nav_item.title = @"Message";
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
	[self textViewDidEndEditing:self.MessageView];
	
}

- (void) animationCompleted : (id) sender {
    [[[DELEGATE window] viewWithTag:255] removeFromSuperview];
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	
	if(range.length > text.length){
		return YES;
	}else if([[textView text] length] + text.length > 200){
		return NO;
	}
	
	return YES;	
}


- (void)dealloc {
	
	[api_Tyke cancelCurrentRequest];
    [arr_Data release];
	[api_Tyke release];
    [super dealloc];
}


@end
