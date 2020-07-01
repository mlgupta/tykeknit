//
//  AddAddresbookFriendsViewController.m
//  SpotWorld
//
//  Created by Abhinit Tiwari on 14/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddAddressbookFriendsViewController.h"
#import "JSON.h"
#import "VXTImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "FaceBookEngine.h"
#import "VXTURLRequest.h"
#import <AddressBook/AddressBook.h>
#import "Messages.h"
#import "Global.h"

@implementation AddAddressbookFriendsViewController
@synthesize theTableView,dict_selectedFriends,tyke_friends,simple_friends;
@synthesize friendsCount, addressBook_Friends,isDryRun,NoOfFriendsToUpdate;

- (void)viewDidLoad {
	
	self.navigationItem.titleView  = [DELEGATE getTykeTitleViewWithTitle:@"Add"];
	
//	CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.5f].CGColor;
//	CGColorRef lightColor = [UIColor clearColor].CGColor;
//	
//	CAGradientLayer *newShadow = [[[CAGradientLayer alloc] init] autorelease];
//	newShadow.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.width, 7);
//	newShadow.colors = [NSArray arrayWithObjects:(id)darkColor, (id)lightColor, nil];
//	[self.navigationController.navigationBar.layer addSublayer:newShadow];	
	//
	api = [[TykeKnitApi alloc]init];
	api.delegate = self;


	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	[btn_done addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn_done] autorelease];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	UIButton *btn = [DELEGATE getBackBarButton];
	[btn addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn] autorelease];
	
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	[self.theTableView setBackgroundColor:[UIColor clearColor]];
	[super viewDidLoad];
	
	self.addressBook_Friends = [self getPersonNames];

	if (![self.addressBook_Friends count]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Address Book"
													   message:@"No contacts found."
													  delegate:self
											 cancelButtonTitle:@"Ok"
											 otherButtonTitles:nil];
		[alert show];
		[alert setTag:300];
		[alert release];
		if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
			[[DELEGATE vi_sideView] setHidden:NO];
		}
			
	}
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES];
	NSArray *sortDescriptorArray = [[NSArray alloc] initWithObjects:&sortDescriptor count:1];
	
	NSMutableArray *sortDescriptors = [NSMutableArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
	NSArray *sorted_friends = [[NSArray alloc]init];
	sorted_friends = [self.addressBook_Friends sortedArrayUsingDescriptors:sortDescriptors];
	self.addressBook_Friends = (NSMutableArray *)sorted_friends;
	[sortDescriptorArray release];
	[sortDescriptor release];
	

	
	NSMutableArray *arr_contacts = [[NSMutableArray alloc]init];

	
	for (int i=0;i < [self.addressBook_Friends count];i++) {
		if ([[[self.addressBook_Friends objectAtIndex:i] objectForKey:@"email"] isEqualToString:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"email"]]) {
				[self.addressBook_Friends removeObjectAtIndex:i];
			}
	}
	self.NoOfFriendsToUpdate = 50;
//	NSMutableArray *emailArray = [self getPersonNames];
//	for (int i = 0; i < self.NoOfFriendsToUpdate; i++) {
//		NSMutableDictionary *uidDict = [[NSMutableDictionary alloc] init];
//		[uidDict setObject:[[self.addressBook_Friends objectAtIndex:i] objectForKey:@"email"] forKey:@"email"];
//		[arr_contacts addObject:uidDict];
//		[uidDict release];
//	}
	
	for (NSDictionary *friend in self.addressBook_Friends) {
		NSMutableDictionary *uidDict = [[NSMutableDictionary alloc] init];
		[uidDict setObject:[friend objectForKey:@"email"] forKey:@"email"];
		[arr_contacts addObject:uidDict];
		[uidDict release];
	}

	
	NSMutableDictionary *dd = [[NSMutableDictionary alloc]init];
	[dd setObject:arr_contacts forKey:@"Contacts"];
	[arr_contacts release];
	
	NSString *str = [dd JSONRepresentation];
	self.isDryRun = YES;
	[DELEGATE addLoadingView:self.vi_main];
	[dd release];
	[api uploadContacts:str isDryRun:@"1"];
	
	selectedFriends = [[NSMutableSet alloc] init];
}

#pragma mark -
#pragma mark UIAlertViewDelegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 300) {
		[self popViewController];
	}
}


- (void) backPressed : (id) sender {
	[self.tyke_friends removeAllObjects];
	[self.simple_friends removeAllObjects];
	if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
		[[DELEGATE vi_sideView] setHidden:NO];
	}
	[self popViewController];
}
#pragma mark -
#pragma mark TykeKnitApi DELEGATE calls

- (NSMutableArray *)getPersonNames
{
	
	NSMutableArray *tempArray  = [[NSMutableArray alloc] init];
	
	ABAddressBookRef addressBook = ABAddressBookCreate();
	CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
	CFMutableArrayRef peopleMutable = CFArrayCreateMutableCopy(
															   kCFAllocatorDefault,
															   CFArrayGetCount(people),
															   people
															   );
	
	self.friendsCount = CFArrayGetCount(people);
	CFArraySortValues(
					  peopleMutable,
					  CFRangeMake(0, CFArrayGetCount(peopleMutable)),
					  (CFComparatorFunction) ABPersonComparePeopleByName,
					  (void*) ABPersonGetSortOrdering()
					  );
	for (int i=0; i <= self.friendsCount-1; i++) 
	{		

		ABRecordRef person = CFArrayGetValueAtIndex(peopleMutable, i);
		//ABRecordRef person = ABAddressBookGetPersonWithRecordID(ab, (ABRecordID) i);
		if (person) {
			ABMultiValueRef emailmulti = ABRecordCopyValue(person, kABPersonEmailProperty);
			CFIndex emailCount = ABMultiValueGetCount(emailmulti);

			if( emailCount > 0 )
			{
				NSString *ee = [[[NSString alloc] initWithFormat:@"%@", ABMultiValueCopyValueAtIndex(emailmulti,0)] autorelease];
//				TxtLog([NSMutableString stringWithString:ee]);
				
				if(isValidString(ee)) {
					NSString *name = (NSString *)ABRecordCopyCompositeName(person);
					if (!name) {
						name = ee;
					}
					[tempArray addObject:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:ee, name, nil] forKeys:[NSArray arrayWithObjects:@"email", @"name", nil]]];
				}
			}
		}
	}
	
	CFRelease(addressBook);
	CFRelease(people);
	CFRelease(peopleMutable);
	
	return [tempArray autorelease];
}

#pragma mark -
#pragma mark UITableViewDelegate & dataSource methods.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
//	int rowIndex = indexPath.row;
	NSString *friendCell = @"friendCell";
	UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:friendCell];
	if(cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:friendCell] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
	
		UIButton *btn_selectChild = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_selectChild.tag = 1;
		btn_selectChild.selected = NO;
		[btn_selectChild setFrame:CGRectMake(10, 3, 31, 31)];
		[btn_selectChild setBackgroundColor:[UIColor clearColor]];
		[btn_selectChild addTarget:self action:@selector(selectChild:) forControlEvents:UIControlEventTouchUpInside];
		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];
		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_selectedTyke.png")] forState:UIControlStateSelected];		
		[cell.contentView addSubview:btn_selectChild];
		
		UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(50, 3, 200, 15)];
		lblFirstName.tag = 2; 
		[lblFirstName setTextColor:[UIColor lightGrayColor]];
		lblFirstName.backgroundColor = [UIColor clearColor];
		lblFirstName.font =[UIFont fontWithName:@"helvetica Neue" size:14];
		lblFirstName.font = [UIFont boldSystemFontOfSize:14];
		[cell.contentView addSubview:lblFirstName];
		[lblFirstName release];
		
		UILabel *lbl_email = [[UILabel alloc]initWithFrame:CGRectMake(50, 18, 200, 20)];
		[lbl_email setTag:3];
		[lbl_email setTextColor:[UIColor lightGrayColor]];
		[lbl_email setBackgroundColor:[UIColor clearColor]];
		lbl_email.font = [UIFont fontWithName:@"helvetica Neue" size:10];
		lbl_email.font = [UIFont boldSystemFontOfSize:13];
		[cell.contentView addSubview:lbl_email];
		[lbl_email release];
		
	}

	UILabel *lblFirstName = (UILabel*)[cell viewWithTag:2];
	UILabel *lbl_email = (UILabel *)[cell viewWithTag:3];
	UIButton *btn_selectChild = (UIButton *)[cell.contentView viewWithTag:1];
	btn_selectChild.selected = NO;	
	
	NSDictionary *dict_data = nil;

	
	
	if (indexPath.section == 0) {
		
		if ([self.tyke_friends count]) {
			dict_data = [self.tyke_friends objectAtIndex:indexPath.row];

			if (isValidString([dict_data objectForKey:@"email"])) {
				if ([selectedFriends containsObject:[dict_data objectForKey:@"email"]]) {
					btn_selectChild.selected = YES;
				} 
			} 	
			
			lblFirstName.textColor = [UIColor darkGrayColor];
			lbl_email.textColor =  [UIColor darkGrayColor];
		}else if ([self.simple_friends count]) {
			dict_data = [self.simple_friends objectAtIndex:indexPath.row];
			
			if (isValidString([dict_data objectForKey:@"email"])) {
				if ([selectedFriends containsObject:[dict_data objectForKey:@"email"]]) {
					btn_selectChild.selected = YES;
				} 
			} 	
			
			lblFirstName.textColor = [UIColor lightGrayColor];
			lbl_email.textColor =  [UIColor lightGrayColor];
		}
		
		
		lblFirstName.text = [NSString stringWithFormat:@"%@",[dict_data objectForKey:@"name"]];
		lbl_email.text =[NSString stringWithFormat:@"%@",[dict_data objectForKey:@"email"]];
		
	}else if (indexPath.section == 1) {
		if ([self.simple_friends count]) {
			dict_data = [self.simple_friends objectAtIndex:indexPath.row];
			
			if (isValidString([dict_data objectForKey:@"email"])) {
				if ([selectedFriends containsObject:[dict_data objectForKey:@"email"]]) {
					btn_selectChild.selected = YES;
				} 
			} 	
			
			lblFirstName.textColor = [UIColor lightGrayColor];
			lbl_email.textColor =  [UIColor lightGrayColor];
		}
		lblFirstName.text = [NSString stringWithFormat:@"%@",[dict_data objectForKey:@"name"]];
		lbl_email.text =[NSString stringWithFormat:@"%@",[dict_data objectForKey:@"email"]];
	}
	return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 30.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *vi = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
	vi.backgroundColor = [UIColor clearColor];
	
	UILabel *lbl_head = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 280, 20)];
	lbl_head.font = [UIFont boldSystemFontOfSize:15];
	lbl_head.backgroundColor = [UIColor clearColor];
	lbl_head.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
	lbl_head.shadowColor = [UIColor whiteColor];
	lbl_head.shadowOffset = CGSizeMake( 0, 1);
	[vi addSubview:lbl_head];
	[lbl_head release];
	
	if (section == 0) {
		if ([self.tyke_friends count]) {
			lbl_head.text = @"TykeKnit Users";
		}else {
			lbl_head.text = @"Invite To Join";
		}
	}
	if (section == 1) {
		if ([self.simple_friends count]) {
			lbl_head.text = @"Invite To Join";
		}
	}
	return [vi autorelease];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	
	if ([self.tyke_friends count]) {
				return 2;
		}
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	int RET = 0;
	if (section == 0) {
		if ([self.tyke_friends count]) {
			RET = [self.tyke_friends count];
		}else if ([self.simple_friends count]) {
			RET = [self.simple_friends count];
		}
	}else if (section == 1) {
		if ([self.simple_friends count]) {
			RET = [self.simple_friends count];
		}
	}
	return RET;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Load the friend profile here.
	UITableViewCell *cell = (UITableViewCell *)[self.theTableView cellForRowAtIndexPath:indexPath];
	
	UIButton *btn_selectChild = (UIButton *)[cell.contentView viewWithTag:1];
	[self selectChild:btn_selectChild];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) selectChild : (id) sender {
	
	UIButton *btn_selectChild = (UIButton *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[btn_selectChild superview] superview];
	UILabel *lbl_email = (UILabel *)[cell.contentView viewWithTag:3];
	NSString *str_email = lbl_email.text;
	NSMutableDictionary *dict = nil;
	NSMutableArray *arr = nil;

	if ([selectedFriends containsObject:str_email]) {
		arr = [self.dict_selectedFriends objectForKey:@"Contacts"];//Emails
		for (int i=0; i < [arr count]; i++) {
			if ([[[arr objectAtIndex:i] objectForKey:@"email"] isEqualToString:str_email]) {
				[arr removeObject:[arr objectAtIndex:i]];
			}
		}

		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];
		btn_selectChild.selected = NO;
		[selectedFriends removeObject:str_email];
	}else {
		self.navigationItem.rightBarButtonItem.enabled = YES;
		if (!self.dict_selectedFriends) {
			self.dict_selectedFriends = [[NSMutableDictionary alloc]init];
			NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
			NSMutableArray *arr = [[NSMutableArray alloc]init];
			
			[dict setObject:str_email forKey:@"email"];
			[arr addObject:dict];
			[dict release];
			[self.dict_selectedFriends setObject:arr forKey:@"Contacts"];//Emails
			
			
			[arr release];
		}else {
			arr = [self.dict_selectedFriends objectForKey:@"Contacts"];//Emails
			dict = [[NSMutableDictionary alloc]init];
			[dict setObject:str_email forKey:@"email"];
			[arr addObject:dict];
			[dict release];
		}
		btn_selectChild.selected = YES;		
		[selectedFriends addObject:str_email];
	}
	
	if (![[self.dict_selectedFriends objectForKey:@"Contacts"] count]) {//Emails
		self.navigationItem.rightBarButtonItem.enabled = NO;
	}
	
	
}
- (void) doneClicked : (id) sender {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
	[dict setObject:[self.dict_selectedFriends objectForKey:@"Contacts"] forKey:@"Contacts"];
	NSString *txtEmails =[dict JSONRepresentation];// [self.dict_selectedFriends JSONRepresentation];
	[DELEGATE addLoadingView:self.vi_main];
	self.isDryRun = NO;
	[dict release];
	[api uploadContacts:txtEmails isDryRun:@"0"];
//		[api inviteUsers:txtEmails];
}
- (void) uploadContactsResponse : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];

		if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
			if (self.isDryRun) {
				if (!self.tyke_friends) {
					self.tyke_friends = [[NSMutableArray alloc]init];
				}
				for (NSMutableDictionary *dict1 in self.addressBook_Friends) {
					for (NSMutableDictionary *dict2 in [[response objectForKey:@"response"] objectForKey:@"Contacts"]) {
						if ([[dict1 objectForKey:@"email"] isEqualToString:[dict2 objectForKey:@"email"]] && [[dict2 objectForKey:@"isMember"] intValue]) {
							[dict2 setObject:[dict1 objectForKey:@"name"] forKey:@"name"];
							[self.tyke_friends addObject:dict2];
						}
					}
				}
				if (!self.simple_friends) {
					self.simple_friends = [[NSMutableArray alloc]init];
				}				
				for (NSMutableDictionary *dict1 in self.addressBook_Friends) {
					for (NSMutableDictionary *dict2 in [[response objectForKey:@"response"] objectForKey:@"Contacts"]) {
						if ([[dict1 objectForKey:@"email"] isEqualToString:[dict2 objectForKey:@"email"]] && ![[dict2 objectForKey:@"isMember"] intValue]) {
							[dict2 setObject:[dict1 objectForKey:@"name"] forKey:@"name"];
							[self.simple_friends addObject:dict2];
						}
					}
				}
				[self.theTableView reloadData];
			}else {
					UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thank You!" 
																   message:@"We have sent an invitation on your behalf."
																  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
					[alert show];
					[alert release];
				if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
					[[DELEGATE vi_sideView] setHidden:NO];
				}
				[self popViewController];
				}
		}else {
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" 
														   message:@"something gone wrong"
														  delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
			[alert show];
			[alert release];
			if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
				[[DELEGATE vi_sideView] setHidden:NO];
			}
			[self popViewController];
		}
}
- (void) inviteUsersResponse : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Congratulations!" 
													   message:@"invitation send"
													  delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
		[alert show];
		[alert release];
		if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
			[[DELEGATE vi_sideView] setHidden:NO];
		}
		[self popViewController];
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!" 
													   message:@"something gone wrong"
													  delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
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


- (void)dealloc {
	[addressBook_Friends release];
	[tyke_friends release];
	[simple_friends release];
	[dict_selectedFriends release];
	
	[selectedFriends release];

	theTableView.delegate = nil;
	theTableView.dataSource = nil;
	[theTableView release];
	
	api.delegate = nil;	
	[api release];

	
	[super dealloc];
}


@end
