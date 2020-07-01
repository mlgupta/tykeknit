//
//  emailComposeVC.m
//  TykeKnit
//
//  Created by Abhinit Tiwari on 18/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "InviteFriendsEmailViewController.h"
#import "NSObject+SBJSON.h"
#import "JSON.h"
#import "Messages.h"

@implementation InviteFriendsEmailViewController
@synthesize theTableView,rightSideView,dict_Invitees,areAllEmailIdValid;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 160;

- (void)viewDidLoad {
	
	self.navigationItem.titleView  = [DELEGATE getTykeTitleViewWithTitle:@"Add"];
	animatedDistance = 0.0f;
	
	api = [[TykeKnitApi alloc]init];
	api.delegate = self;
	areAllEmailIdValid = NO;
	
	self.rightSideView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 0, 45, 418)];
	[self.rightSideView setBackgroundColor:[UIColor clearColor]];
	[self.rightSideView setImage:[[UIImage imageNamed:@"tab_grad.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:22]];
	[self.rightSideView setAlpha:1.0];
	[self.view addSubview:self.rightSideView];
	[self.rightSideView release];
	
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn_back] autorelease];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	[self.theTableView setBackgroundColor:[UIColor clearColor]];
	numberOfRows = 1;
	[super viewDidLoad];

	UILabel *lbl_info = [[UILabel alloc]initWithFrame:CGRectMake(20, 35, 260, 40)];
	lbl_info.numberOfLines = 0;
	[lbl_info setFont:[UIFont fontWithName:@"helvetica Neue" size:12]];
	[lbl_info setFont:[UIFont systemFontOfSize:12]];
	[lbl_info setTextColor:[UIColor darkGrayColor]];
	[lbl_info setBackgroundColor:[UIColor clearColor]];
	lbl_info.text = @"Invite your friends to join your knit by simply providing us their email addresses.";
	[self.view addSubview:lbl_info];
	[lbl_info release];
}

- (void) backPressed : (id) sender {
	if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
		[[DELEGATE vi_sideView] setHidden:NO];
	}
	
	[self popViewController];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0) {
		NSString *friendCell = @"emailCell";
		UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:friendCell];
		if(cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendCell] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
						
			UITextField *txt_Cell = [[UITextField alloc]initWithFrame:CGRectMake(14, 10, 240, 20)];
			[txt_Cell setFont:[UIFont systemFontOfSize:15]];
			txt_Cell.autocorrectionType = UITextAutocorrectionTypeNo;
			[txt_Cell addTarget:self action:@selector(editingStart:) forControlEvents:UIControlEventEditingDidBegin];
			[txt_Cell addTarget:self action:@selector(nextPressed:) forControlEvents:UIControlEventEditingDidEndOnExit];
			[txt_Cell addTarget:self action:@selector(editingEnded:) forControlEvents:UIControlEventEditingDidEnd];
			[txt_Cell setAutocapitalizationType:UITextAutocapitalizationTypeNone];
			[txt_Cell setKeyboardType:UIKeyboardTypeEmailAddress];
			txt_Cell.placeholder = @"Email";
			txt_Cell.tag = 1;
			[cell.contentView addSubview:txt_Cell];
			[txt_Cell release];
			
			UIButton *btn_addMore = [UIButton buttonWithType:UIButtonTypeContactAdd];
			btn_addMore.tag = 2;
			btn_addMore.frame = CGRectMake(257, 5, 30, 30);
			[btn_addMore addTarget:self action:@selector(btn_addMore:) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:btn_addMore];
			
		}
		UITextField *txt_Cell = (UITextField *)[cell.contentView viewWithTag:1];
		UIButton *btn_addMore = (UIButton *)[cell.contentView viewWithTag:2];
		
		if ([self.theTableView numberOfRowsInSection:0] == indexPath.row+1) {
			btn_addMore.hidden = NO;
		}else {
			btn_addMore.hidden = YES;
		}
		
		if ([[self.dict_Invitees objectForKey:@"Emails"] count] > indexPath.row) {
			if ([[self.dict_Invitees objectForKey:@"Emails"] objectAtIndex:indexPath.row]) {
				txt_Cell.text = [[[self.dict_Invitees objectForKey:@"Emails"] objectAtIndex:indexPath.row] objectForKey:@"email"];
			}
		}else{ 
			txt_Cell.text = @"";
		}
		self.theTableView.separatorColor = [UIColor grayColor];
		return cell;//[self.dictTykeData count]*3;
	}else if (indexPath.section == 1) {
			NSString *friendCell = @"btnCell";
			UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:friendCell];
			if(cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendCell] autorelease];
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleGray;
				cell.backgroundColor = [UIColor clearColor];
					
				UIButton *btn_sendEmail = [UIButton buttonWithType:UIButtonTypeCustom];
				[btn_sendEmail addTarget:self action:@selector(btn_sendEmailClicked:) forControlEvents:UIControlEventTouchUpInside];
				[btn_sendEmail setBackgroundImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_sendEmail.png")] forState:UIControlStateNormal];
				[btn_sendEmail setFrame:CGRectMake(20, -10, 260, 45)];
				[cell.contentView addSubview:btn_sendEmail];
			}
		self.theTableView.separatorColor = [UIColor clearColor];
		return cell;	
	}
	return nil;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 2;//[self.dictTykeData count]*3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == 0) {
		return numberOfRows;
	}
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 40;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (void) editingStart : (id) sender {
	
	UITextField *textField = (UITextField*)sender;
	CGRect textFieldRect = [self.view convertRect:textField.bounds fromView:textField];
	CGRect viewRect = [self.view convertRect:self.view.bounds fromView:self.view];
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
	
	CGRect viewFrame = self.view.frame;
	viewFrame.origin.y -= animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	
	[self.view setFrame:viewFrame];
	[UIView commitAnimations];
	 
}
- (void) nextPressed : (id) sender {
	UITextField *txt_email = (UITextField *) sender;
	[txt_email resignFirstResponder];

}

-(void) editingEnded : (id) sender {
	UITextField *txt_email = (UITextField *) sender;
	UITableViewCell *cell = (UITableViewCell *)[[sender superview] superview];
	[txt_email resignFirstResponder];
	if (self.dict_Invitees) {
		if ([[self.dict_Invitees objectForKey:@"Emails"] count] > [self.theTableView indexPathForCell:cell].row) {
			[[self.dict_Invitees objectForKey:@"Emails"] removeObjectAtIndex:[self.theTableView indexPathForCell:cell].row];
		}
	}
	
	NSString *email =txt_email.text;
	
		NSMutableArray *arr =  nil;
		NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
		[dict setObject:email forKey:@"email"];
		if (!self.dict_Invitees) {
			self.dict_Invitees = [[NSMutableDictionary alloc]init];
			arr = [[NSMutableArray alloc]init];
			[arr addObject:dict];
			[dict release];	
			[self.dict_Invitees setObject:arr forKey:@"Emails"];
			[arr release];
		}else {
			arr = [self.dict_Invitees objectForKey:@"Emails"];
			if (!arr) {
				arr =[[NSMutableArray alloc]init];
				[arr insertObject:dict atIndex:[self.theTableView indexPathForCell:cell].row];// addObject :dict];
				[self.dict_Invitees setObject:arr forKey:@"Emails"];
				[arr release];
			}else {
				[arr insertObject:dict atIndex:[self.theTableView indexPathForCell:cell].row];//				[arr addObject:dict];
			}
			[dict release];
		}
	
	CGRect viewFrame = [self.view frame];
	viewFrame.origin.y += animatedDistance;
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
	[self.view setFrame:viewFrame];
	[UIView commitAnimations];
	
	[sender resignFirstResponder];
	
}
- (void) btn_sendEmailClicked: (id) sender {
	[self.view endEditing:YES];
	areAllEmailIdValid = NO;
	if (self.dict_Invitees) {
		
		NSMutableArray *arr = [self.dict_Invitees objectForKey:@"Emails"];
		for (int i = 0;i < [arr count];i++) {
			NSDictionary *dict = [arr objectAtIndex:i];
			if (isValidEmailAddress([dict objectForKey:@"email"])) {
				areAllEmailIdValid = YES;
				break;
			}
		}
	}
	
	if (areAllEmailIdValid) {
		NSString *str_users = [self.dict_Invitees JSONRepresentation];
		[DELEGATE addLoadingView:self.vi_main];
		[api inviteUsers:str_users];
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!"
													   message:@"Invalid Email Address"
													  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}	
	
}
- (void) btn_addMore: (id)sender {

	UIButton *btn = (UIButton *)sender;
//	UITableViewCell *cell = (UITableViewCell *)[[sender superview ] superview];
//	UITextField *txt_Field = (UITextField *) [cell.contentView viewWithTag:1];
	
	areAllEmailIdValid = YES;
	NSMutableArray *arr = [self.dict_Invitees objectForKey:@"Emails"];
	for (int i = 0;i < [arr count];i++) {
		NSDictionary *dict = [arr objectAtIndex:i];
		if (!isValidEmailAddress([dict objectForKey:@"email"])) {
			areAllEmailIdValid = NO;
			break;
		}
	}
	if (areAllEmailIdValid) {
		[btn setHidden:YES];
		NSArray *arr = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:[self.theTableView numberOfRowsInSection:0] inSection:0]];
		numberOfRows+=1;
		[self.theTableView insertRowsAtIndexPaths:arr withRowAnimation:UITableViewRowAnimationLeft];
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!"
													   message:@"Invalid Email Address"
													  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}	
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void) inviteUsersResponse : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thank You!" 
													   message:@" We have sent an invitation on your behalf."
													  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert setTag:300];
		[alert show];
		[alert release];
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" 
													   message:@"something gone wrong"
													  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
	[alert show];
	[alert release];
	}
	
}
- (void) noNetworkConnection {
	
	[DELEGATE removeLoadingView:self.vi_main];
}

- (void) failWithError : (NSError*) error {
	
	[DELEGATE removeLoadingView:self.vi_main];
}

- (void) requestCanceled {
	
	[DELEGATE removeLoadingView:self.vi_main];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 300) {
		if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
			[[DELEGATE vi_sideView] setHidden:NO];
		}
		
		[self popViewController];
	}
}
- (void)dealloc {
    [super dealloc];
}


@end
