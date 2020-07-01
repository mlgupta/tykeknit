//
//  AddFacebookFriendsViewController.m
//  SpotWorld
//
//  Created by Abhinit Tiwari on 14/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddFacebookFriendsViewController.h"

#import "JSON.h"
#import "VXTImageView.h"
#import <QuartzCore/QuartzCore.h>
#import "FaceBookEngine.h"
#import "VXTURLRequest.h"
#import "Messages.h"

@implementation AddFacebookFriendsViewController
@synthesize theTableView,api;
//Synthesize Views
@synthesize topView, middleView;

//Synthesize Other Vars
@synthesize friendsCount, friendsArray,dict_selectedFriends,friendsArray1,userhasFBFriends;

- (void)viewDidLoad {	
	self.navigationItem.titleView  = [DELEGATE getTykeTitleViewWithTitle:@"Invite"];

    api = [[TykeKnitApi alloc]init];
	api.delegate = self;

	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	[btn_done addTarget:self action:@selector(doneClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn_done] autorelease];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	
	UIButton *btn = [DELEGATE getBackBarButton];
	[btn addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn] autorelease];

	NSMutableArray *fbFriends = [[NSMutableArray alloc]init];
	for (NSMutableDictionary *dict in self.friendsArray) {
		[fbFriends addObject:[dict objectForKey:@"uid"]];
	}
	NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
	[dict setObject:fbFriends forKey:@"FBContacts"];
	
	NSString *txtEmails = [dict JSONRepresentation];
	
	[self.view setBackgroundColor:[UIColor blackColor]];
	[self.theTableView setBackgroundColor:[UIColor clearColor]];
	[super viewDidLoad];   

    [DELEGATE addLoadingView:self.vi_main];
	[api uploadFBContacts:txtEmails];
}

- (void) uploadFBContactsResponse : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
			[[DELEGATE vi_sideView] setHidden:YES];
		}
		
        if ([[response objectForKey:@"response"] objectForKey:@"FBContacts"]) {
            if (!self.friendsArray1) {
                self.friendsArray1 = [[NSMutableArray alloc]init];
            }
            for (NSMutableDictionary *dict1 in [[response objectForKey:@"response"] objectForKey:@"FBContacts"]) {
                [self.friendsArray1 addObject:dict1];

            }
            [self.theTableView reloadData];
        }
        if (![self.friendsArray1 count]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"FaceBook"
                                                           message:@"None of your Facebook friends are currently using TykeKnit. You can invite them through email."
                                                          delegate:self
                                                 cancelButtonTitle:@"Ok"
                                                 otherButtonTitles:nil];
            [alert show];
            [alert setTag:300];
            [alert release];
            if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
                [[DELEGATE vi_sideView] setHidden:NO];
            }
            [self popViewController];
        }
	}
}	

- (void) backPressed : (id) sender {
	if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
		[[DELEGATE vi_sideView] setHidden:NO];
	}
	
	[self popViewController];
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
		
		UIButton *btn_selectChild = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_selectChild.tag = 1;
		btn_selectChild.selected = NO;
		[btn_selectChild setFrame:CGRectMake(10, 3, 31, 31)];
		[btn_selectChild setBackgroundColor:[UIColor clearColor]];
		[btn_selectChild addTarget:self action:@selector(selectChild:) forControlEvents:UIControlEventTouchUpInside];
		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];
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
	UIButton *btn_selectChild = (UIButton *)[cell viewWithTag:1];
	UILabel *lblFirstName = (UILabel*)[cell viewWithTag:2];
	UILabel *lbl_email = (UILabel *)[cell viewWithTag:3];
		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];	
	NSDictionary *dict_data = [self.friendsArray1 objectAtIndex:indexPath.row];
	
	lblFirstName.text = [NSString stringWithFormat:@"%@ %@",[dict_data objectForKey:@"txtUserFname"],[dict_data objectForKey:@"txtUserLname"]];
	lbl_email.text =[NSString stringWithFormat:@"%@",[dict_data objectForKey:@"txtUserEmail"]];
//	NSArray *arr = [self.dict_selectedFriends objectForKey:@"FBContacts"];
//	NSNumber *numUid = [NSNumber numberWithInt:[[dict_data objectForKey:@"uid"]intValue]];
//	if ([arr count]) {
//		for (NSNumber *uid in arr) {
//			if ([uid isEqualToNumber:numUid]) {
//				[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_selectedTyke.png")] forState:UIControlStateNormal];
//			}
//		}
//	}
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.friendsArray1 count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//Load the friend profile here.
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark API DELEGATE
- (void) doneClicked : (id) sender {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
	[dict setObject:[self.dict_selectedFriends objectForKey:@"Contacts"] forKey:@"Contacts"];
	NSString *txtEmails =[dict JSONRepresentation];// [self.dict_selectedFriends JSONRepresentation];
	[dict release];
	[DELEGATE addLoadingView:self.vi_main];
	[api uploadContacts:txtEmails isDryRun:@"0"];
}

- (void) uploadContactsResponse : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
    
    if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"FaceBook" 
                                                           message:@"Invitations Sent."
                                                          delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            [alert release];
            if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
                [[DELEGATE vi_sideView] setHidden:NO];
            }
            [self popViewController];
    }else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"FaceBook" 
                                                       message:@"Error Sending Invitations."
                                                      delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        [alert release];
        if ([self.navigationController isEqual:[DELEGATE nav_dashBoard]]) {
            [[DELEGATE vi_sideView] setHidden:NO];
        }
        [self popViewController];
    }
}

- (void) selectChild : (id) sender {
	
	UIButton *btn_selectChild = (UIButton *)sender;
	UITableViewCell *cell = (UITableViewCell *)[[btn_selectChild superview] superview];
	UILabel *lbl_email = (UILabel *)[cell.contentView viewWithTag:3];
	NSString *str_email = lbl_email.text;
	NSMutableDictionary *dict1 = nil;
	NSMutableArray *arr = nil;
	
	if (btn_selectChild.selected) {
		arr = [self.dict_selectedFriends objectForKey:@"FBContacts"];
		for (int i=0; i < [arr count]; i++) {
			if ([[[arr objectAtIndex:i] objectForKey:@"txtUserEmail"] isEqualToString:str_email]) {
				[arr removeObject:[arr objectAtIndex:i]];
			}
		}
		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];
		btn_selectChild.selected = NO;
	}else {
		self.navigationItem.rightBarButtonItem.enabled = YES;
		
		if (!self.dict_selectedFriends) {
			self.dict_selectedFriends = [[NSMutableDictionary alloc]init];
			arr = [[NSMutableArray alloc]init];

            dict1 = [[NSMutableDictionary alloc]init];

            [dict1 setObject:str_email forKey:@"email"];
            [arr addObject:dict1];
            [dict1 release];

            [self.dict_selectedFriends setObject:arr forKey:@"Contacts"];
            [arr release];
		}else {
			arr = [self.dict_selectedFriends objectForKey:@"Contacts"];

            dict1 = [[NSMutableDictionary alloc]init];

            [dict1 setObject:str_email forKey:@"email"];
            [arr addObject:dict1];
            [dict1 release];
		}
		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_selectedTyke.png")] forState:UIControlStateNormal];
		btn_selectChild.selected = YES;		
	}
	
	if (![[self.dict_selectedFriends objectForKey:@"Contacts"] count]) {
		self.navigationItem.rightBarButtonItem.enabled = NO;
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
	[self.friendsArray release];
	[self.friendsArray1 release];
	[self.topView release];
	[self.middleView release];
    [super dealloc];
}

@end