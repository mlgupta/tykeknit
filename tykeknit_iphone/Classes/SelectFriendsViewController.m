//
//  SelectFriendsViewController.m
//  TykeKnit
//
//  Created by Ver on 14/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SelectFriendsViewController.h"
#import "Global.h"
#import "JSON.h"


@implementation SelectFriendsViewController
@synthesize theTableView,arr_friendsData,api_tyke;
@synthesize dict_messageData;

- (void)viewWillAppear:(BOOL)animated {
	if ([self.dict_messageData objectForKey:@"friends"]) {
		[self.theTableView reloadData];
	}
}
- (void)viewDidLoad {
	
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Friends"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];
	
	api_tyke = [[TykeKnitApi alloc] init];
	api_tyke.delegate = self;
	self.arr_friendsData = [[NSMutableArray alloc]init];
	
	//	self.arr_data = [DELEGATE arr_kidsList];
	if (![self.arr_friendsData count]) {
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke getFriends];
	}
	
	[super viewDidLoad];
}

-(void) backPressed:(id)sender{
	
	[self popViewController];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if ([self.arr_friendsData count]) {
		return [self.arr_friendsData count];
	}else return 1;

}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	float RET=0.0;
	if (section==0) {
		RET =30.0;
	}
	return RET;
}	
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *view_ForHeader = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 150, 20)];
	UILabel *lbl_header = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 100, 15)];
	[lbl_header setFont:[UIFont boldSystemFontOfSize:14]];
	[lbl_header setTextColor:[UIColor darkGrayColor]];
	[lbl_header setBackgroundColor:[UIColor clearColor]];
	if ([self.arr_friendsData count]) {
		[lbl_header setText:@"Friends"];
	}
	[view_ForHeader addSubview:lbl_header];
	[lbl_header release];
	return [view_ForHeader autorelease];	
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell = nil;
	
	if (indexPath.section==0) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"section 0"];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"section 0"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UIButton *btn_selectChild = [UIButton buttonWithType:UIButtonTypeCustom];
			btn_selectChild.tag = 1;
			btn_selectChild.selected = NO;
			[btn_selectChild setFrame:CGRectMake(10, 3, 31, 31)];
			[btn_selectChild setBackgroundColor:[UIColor clearColor]];
			[btn_selectChild addTarget:self action:@selector(selectChild:) forControlEvents:UIControlEventTouchUpInside];
			[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];
			[cell.contentView addSubview:btn_selectChild];
			
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 100, 20)];
			lblFirstName.tag = 2; 
			[lblFirstName setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font =[UIFont fontWithName:@"helvetica Neue" size:14];
			lblFirstName.font = [UIFont boldSystemFontOfSize:14];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
			
			UILabel *lbl_childAge = [[UILabel alloc]initWithFrame:CGRectMake(120, 12, 100, 20)];
			[lbl_childAge setTag:3];
			[lbl_childAge setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			[lbl_childAge setBackgroundColor:[UIColor clearColor]];
			lbl_childAge.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			lbl_childAge.font = [UIFont boldSystemFontOfSize:13];
			[cell.contentView addSubview:lbl_childAge];
			[lbl_childAge release];
			
		}
		UIButton *btn_selectChild = (UIButton *)[cell.contentView viewWithTag:1];
		UILabel *lblFirstName = (UILabel *)[cell.contentView viewWithTag:2];
		UILabel *lbl_childAge = (UILabel *)[cell.contentView viewWithTag:3];
		
		if (![self.arr_friendsData count]) {
			cell.textLabel.text = @"You do not have any friends";
			cell.textLabel.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			[cell.textLabel setFont:[UIFont systemFontOfSize:14]];
			btn_selectChild.hidden = YES;
			lblFirstName.text = @"";
			lbl_childAge.text = @"";
			return cell;
		}
		if (indexPath.section==0) {
			//		lblFirstName.textColor = [UIColor colorWithRed:0.302 green:0.604 blue:0.122 alpha:1.0];
			//			lbl_childAge.textColor = [UIColor colorWithRed:0.302 green:0.604 blue:0.122 alpha:1.0];
			cell.textLabel.text = @"";
			btn_selectChild.hidden = NO;			
			if ([[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"firstName"] && [[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"lastName"]) {
				lblFirstName.text  =[NSString stringWithFormat:@"%@ %@",[[[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"firstName"] capitalizedString],[[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"lastName"]];
			}
			
			if ([[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"txtDOB"]) {
				NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
				[formatter setDateFormat:@"yyyy-MM-dd"];
				lbl_childAge.text = [NSString stringWithFormat:@"(%@)",getChildAgeFromDate([formatter dateFromString:[[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"txtDOB"]])];
				[formatter release];
			}
			if ([[[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"txtGender"] isEqualToString:@"M"]) {
				lbl_childAge.textColor = BoyBlueColor;
			}else {
				lbl_childAge.textColor = GirlPinkColor;
			}
			
			if ([self.dict_messageData objectForKey:@"friends"]) {
				if ([[[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"id"] isEqualToString:[[self.dict_messageData objectForKey:@"friends"] objectForKey:@"id"]]) {
					[btn_selectChild setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_selectedTyke")] forState:UIControlStateNormal];
					btn_selectChild.selected = YES;		
				}else {
					[btn_selectChild setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_deselectTyke")] forState:UIControlStateNormal];
					btn_selectChild.selected = NO;		
				}
			}
			
			
		}
		/*		if (indexPath.section==1) {
		 if ([[self.arr_inKnitfriends objectAtIndex:indexPath.row] objectForKey:@"txtFirstName"] && [[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtLastName"]) {
		 lblFirstName.text  =[NSString stringWithFormat:@"%@ %@",[[[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtFirstName"] capitalizedString],[[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtLastName"]];
		 }
		 
		 if ([[self.arr_inKnitfriends objectAtIndex:indexPath.row] objectForKey:@"txtDOB"]) {
		 NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
		 [formatter setDateFormat:@"yyyy-MM-dd"];
		 lbl_childAge.text = [NSString stringWithFormat:@"(%d)",getAge([formatter dateFromString:[[self.arr_wannaHangfriends objectAtIndex:indexPath.row] objectForKey:@"DOB"]])];
		 [formatter release];
		 }
		 if ([[[self.arr_inKnitfriends objectAtIndex:indexPath.row] objectForKey:@"txtGender"] isEqualToString:@"M"]) {
		 lbl_childAge.textColor = [UIColor colorWithRed:0.498 green:0.733 blue:0.831 alpha:1.0];
		 }else {
		 lbl_childAge.textColor = [UIColor colorWithRed:0.8784 green:0.0941 blue:0.7215 alpha:1.0];
		 }
		 
		 
		 for (NSDictionary *dict in [self.dict_messageData objectForKey:@"friends"]) {
		 if ([[dict objectForKey:@"cid"] isEqualToString:[[self.arr_inKnitfriends objectAtIndex:indexPath.row]objectForKey:@"cid"]]) {
		 [btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_selectedTyke.png")] forState:UIControlStateNormal];
		 btn_selectChild.selected = YES;		
		 }
		 }
		 
		 }
		 */	
		CGSize aSize = [lblFirstName.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(180, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
		lblFirstName.frame = CGRectMake(50, 10, aSize.width, aSize.height);
		aSize = [lbl_childAge.text sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:CGSizeMake(150, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
		lbl_childAge.frame = CGRectMake(lblFirstName.frame.origin.x+lblFirstName.frame.size.width+3, 12, aSize.width, aSize.height);
		
		cell.tag = indexPath.row;
		
		//		cell.textLabel.text  = [[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtFirstName"];
		/*
		 NSDictionary *dictData = [self.arr_data objectAtIndex:[indexPath row]];
		 //	NSLog(@"scheduledata:%@",[self.dict_messageData objectForKey:@"txtOrganiserCid"]);
		 if ([[self.dict_messageData objectForKey:@"txtOrganiserCid"] isEqualToString:[dictData objectForKey:@"ChildTblPk"]]) {
		 cell.accessoryType = UITableViewCellAccessoryCheckmark;
		 }else {
		 cell.accessoryType = UITableViewCellAccessoryNone;
		 }
		 cell.textLabel.text = [dictData objectForKey:@"fname"];
		 */
	}
	return cell;
	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UITableViewCell *cell = [self.theTableView cellForRowAtIndexPath:indexPath];
	UIButton *btn = (UIButton *)[cell.contentView viewWithTag:1];
	[self selectChild:btn];
	
}

- (void) selectChild : (id) sender {
	UIButton *btn_selectChild = (UIButton *) sender;
	UITableViewCell *cell = (UITableViewCell *)[[btn_selectChild superview] superview];
		NSMutableDictionary *dict = nil;	
	if (btn_selectChild.selected) {

		dict = [self.arr_friendsData objectAtIndex:cell.tag];
		[dict setObject:@"NO" forKey:@"selected"];
		
		if ([[[self.dict_messageData objectForKey:@"friends"] allKeys] count]) {
			[self.dict_messageData removeObjectForKey:@"friends"];
		}
		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];
		btn_selectChild.selected = NO;
	}else {
		dict = [self.arr_friendsData objectAtIndex:cell.tag];
		[dict setObject:@"YES" forKey:@"selected"];
		[self.dict_messageData setObject:dict forKey:@"friends"];
		
		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_selectedTyke.png")] forState:UIControlStateNormal];
		btn_selectChild.selected = YES;		
	}

	[self.theTableView reloadData];
	
	
}



- (void) getFriendsResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		if ([[[response objectForKey:@"response"] objectForKey:@"Friends"] count]) {
			for (NSDictionary *dict in [[response objectForKey:@"response"] objectForKey:@"Friends"]) {
					if ([[dict allKeys] count]) {
						[self.arr_friendsData addObject:dict];
					}
			}
		}

	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Oops!"
													   message:@"You dont have any friends"
													  delegate:self 
											 cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[alert setTag:300];
		[alert show];
		[alert release];
	}

	[self.theTableView reloadData];
[DELEGATE removeLoadingView:nil];

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
	[self.arr_friendsData release];
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}


@end
