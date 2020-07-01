//
//  PlaydateScheduleKidsViewController.m
//  TykeKnit
//
//  Created by Ver on 24/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PlaydateScheduleKidsViewController.h"
#import "Global.h"
#import "JSON.h"
#import "DTCustomColoredAccessory.h"
#import "AddFriendsViewController.h"


@implementation PlaydateScheduleKidsViewController

@synthesize theTableView, dict_scheduleData,api_tyke,child_id;
@synthesize onlyParents,selectedBuddy;

- (void)viewWillAppear:(BOOL)animated {
	
	if ([self.dict_scheduleData objectForKey:@"buddies"]) {
		[self.theTableView reloadData];
	}
	
	[super viewWillAppear:animated];
}

- (void)viewDidLoad {
	
    UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Invite Buddies"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0]];

	self.vi_main.backgroundColor = [UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0];
	self.view.backgroundColor = [UIColor colorWithRed:0.875 green:0.9060 blue:0.9180 alpha:1.0];
	
    if (!expandedSections) {
        expandedSections = [[NSMutableIndexSet alloc] init];
    }
    
	api_tyke = [[TykeKnitApi alloc] init];
	api_tyke.delegate = self;
	onlyParents = YES;
	lbl_errorMsg.hidden = YES;
	
	if ([[self.dict_scheduleData objectForKey:@"buddies"] count] < 2) {
		if ([[self.dict_scheduleData objectForKey:@"buddies"] count]) {
			self.selectedBuddy = [[[self.dict_scheduleData objectForKey:@"buddies"] objectAtIndex:0] objectForKey:@"ParentUserTblPk"];
		}
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke getBuddies:self.child_id];
	}else {
		[self sortBuddies];
	}
/*	
	if (![[self.dict_scheduleData objectForKey:@"buddies"] count]) {
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke getBuddies:self.child_id];
	}else if ([[self.dict_scheduleData objectForKey:@"buddies"] count] == 1) {
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke getBuddies:self.child_id];
	}else {
		[self sortBuddies];
	}
*/
    theTableView.sectionFooterHeight = 5.0;
    theTableView.sectionHeaderHeight = 0.0;    
    
	[super viewDidLoad];
}

- (void) backPressed:(id)sender{
	
	[self popViewController];
}

- (BOOL)tableView:(UITableView *)tableView canCollapseSection:(NSInteger)section {
    return YES;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return [[self.dict_scheduleData objectForKey:@"buddies"] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
		return 40;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
    if ([self tableView:tableView canCollapseSection:section])
    {
        if ([expandedSections containsIndex:section]) {
            return [[[[self.dict_scheduleData objectForKey:@"buddies"] objectAtIndex:section] objectForKey:@"Tykes"] count] + 1;
        }
        return 1;
    }
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	int RET = 0.0f;
	if (section==0) {
		
		RET = 30.0f;
	}else if ([arr_wannaHang count]) {
		
		if ([arr_wannaHang count] == section) {
			RET = 30.0f;
		}
	}
	
	return RET;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *view_ForHeader = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 150, 20)];
	UILabel *lbl_header = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 100, 15)];
	[lbl_header setFont:[UIFont boldSystemFontOfSize:14]];
	[lbl_header setTextColor:[UIColor darkGrayColor]];
	[lbl_header setBackgroundColor:[UIColor clearColor]];
	if (section==0) {
		
		if ([arr_wannaHang count]) {
			[lbl_header setText:@"Wanna Hang"];
		}else {
			[lbl_header setText:@"In Knit"];
		}
	}else if ([arr_wannaHang count]) {
		
		if ([arr_wannaHang count] == section) {
			[lbl_header setText:@"In Knit"];
		}
	}
	
	[view_ForHeader addSubview:lbl_header];
	[lbl_header release];
	return [view_ForHeader autorelease];	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell = nil;
	cell = [tableView dequeueReusableCellWithIdentifier:@"section 0"];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"section 0"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		
		cell.backgroundColor = [UIColor colorWithRed:0.933 green:0.949 blue:0.961 alpha:1.0];
        
		UIButton *btn_selectChild = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_selectChild.tag = 10;
		btn_selectChild.selected = NO;
		[btn_selectChild setFrame:CGRectMake(10, 5, 31, 31)];
		[btn_selectChild setBackgroundColor:[UIColor clearColor]];
		[btn_selectChild addTarget:self action:@selector(selectChild:) forControlEvents:UIControlEventTouchUpInside];
		[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];
		[cell.contentView addSubview:btn_selectChild];
		
		UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(20, 14, 100, 20)];
		lblFirstName.tag = 12; 
		[lblFirstName setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
		lblFirstName.backgroundColor = [UIColor clearColor];
		lblFirstName.font =[UIFont fontWithName:@"helvetica Neue" size:14];
		lblFirstName.font = [UIFont boldSystemFontOfSize:14];
		[cell.contentView addSubview:lblFirstName];
		[lblFirstName release];
		
		UILabel *lbl_childAge = [[UILabel alloc]initWithFrame:CGRectMake(120, 12, 100, 20)];
		[lbl_childAge setTag:14];
		[lbl_childAge setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
		[lbl_childAge setBackgroundColor:[UIColor clearColor]];
		lbl_childAge.font = [UIFont fontWithName:@"helvetica Neue" size:14];
		lbl_childAge.font = [UIFont boldSystemFontOfSize:13];
		[cell.contentView addSubview:lbl_childAge];
		[lbl_childAge release];
	}
	
	UIButton *btn_selectChild = (UIButton *)[cell.contentView viewWithTag:10];
	UILabel *lblFirstName = (UILabel *)[cell.contentView viewWithTag:12];
	UILabel *lbl_childAge = (UILabel *)[cell.contentView viewWithTag:14];

    if (!indexPath.row) {
		
        NSMutableDictionary *dict_data = [[self.dict_scheduleData objectForKey:@"buddies"] objectAtIndex:indexPath.section];

		if ([[dict_data objectForKey:@"selected"] intValue]) {
			[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_selectedTyke.png")] forState:UIControlStateNormal];
		}else {
			[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];
		}
		
		if ([dict_data objectForKey:@"ParentFName"] && [dict_data objectForKey:@"ParentLName"]) {
			lblFirstName.text  =[NSString stringWithFormat:@"%@ %@",[dict_data objectForKey:@"ParentFName"],[dict_data objectForKey:@"ParentLName"]];
		}
        
        if ([expandedSections containsIndex:indexPath.section]) {
            cell.accessoryView = [DTCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:DTCustomColoredAccessoryTypeUp];
        }
        else {
            cell.accessoryView = [DTCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:DTCustomColoredAccessoryTypeDown];
        }
		
		CGSize aSize = [lblFirstName.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(180, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
		lblFirstName.frame = CGRectMake(50, 10, aSize.width, aSize.height);
		aSize = [lbl_childAge.text sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:CGSizeMake(150, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
		lbl_childAge.frame = CGRectMake(lblFirstName.frame.origin.x+lblFirstName.frame.size.width+3, 12, aSize.width, aSize.height);
    }
    else {
        cell.accessoryView = nil;
		NSArray *arr_tykeData = nil;
		NSMutableDictionary *tykeData = nil;
		[btn_selectChild setFrame:CGRectMake(30, 3, 31, 31)];
		
		arr_tykeData = [[[self.dict_scheduleData objectForKey:@"buddies"] objectAtIndex:indexPath.section] objectForKey:@"Tykes"];
		tykeData = [arr_tykeData objectAtIndex:indexPath.row - 1];

        if ([tykeData objectForKey:@"txtFirstName"] && [tykeData objectForKey:@"txtLastName"]) {
            lblFirstName.text  =[NSString stringWithFormat:@"%@ %@",[tykeData objectForKey:@"txtFirstName"],[tykeData objectForKey:@"txtLastName"]];
			
			if ([[tykeData objectForKey:@"WannaHang"] isEqualToString:@"t"]) {
				lblFirstName.textColor = WannaHangColor;
			}else {
				lblFirstName.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			}
        }
        
        if ([tykeData objectForKey:@"txtDOB"]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            lbl_childAge.text = [NSString stringWithFormat:@"(%@)",getChildAgeFromDate([formatter dateFromString:[tykeData objectForKey:@"txtDOB"]])];
            [formatter release];
        }
        
        CGSize aSize = [lblFirstName.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(180, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
        lblFirstName.frame = CGRectMake(60, 10, aSize.width, aSize.height);
        aSize = [lbl_childAge.text sizeWithFont:[UIFont boldSystemFontOfSize:13] constrainedToSize:CGSizeMake(150, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
        lbl_childAge.frame = CGRectMake(lblFirstName.frame.origin.x+lblFirstName.frame.size.width+3, 10, aSize.width, aSize.height);

		if ([[tykeData objectForKey:@"selected"] intValue]) {
			[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_selectedTyke.png")] forState:UIControlStateNormal];
		}else {
			[btn_selectChild setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_deselectTyke.png")] forState:UIControlStateNormal];
		}
		
    }

	cell.tag = indexPath.section;
	cell.contentView.tag = indexPath.row;
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if ([self tableView:tableView canCollapseSection:indexPath.section])
    {
        if (!indexPath.row)
        {
            // only first row toggles exapand/collapse
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            NSInteger section = indexPath.section;
            BOOL currentlyExpanded = [expandedSections containsIndex:section];
            NSInteger rows;
            
            NSMutableArray *tmpArray = [NSMutableArray array];
            
            if (currentlyExpanded)
            {
                rows = [self tableView:tableView numberOfRowsInSection:section];
                [expandedSections removeIndex:section];
            }
            else
            {
                [expandedSections addIndex:section];
                rows = [self tableView:tableView numberOfRowsInSection:section];
            }
            
            for (int i = 1; i<rows; i++)
            {
                NSIndexPath *tmpIndexPath = [NSIndexPath indexPathForRow:i 
                                                               inSection:section];
                [tmpArray addObject:tmpIndexPath];
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

            if (currentlyExpanded)
            {
                [tableView deleteRowsAtIndexPaths:tmpArray 
                                 withRowAnimation:UITableViewRowAnimationTop];
                
                cell.accessoryView = [DTCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:DTCustomColoredAccessoryTypeDown];

            }
            else {
				
                [tableView insertRowsAtIndexPaths:tmpArray 
                                 withRowAnimation:UITableViewRowAnimationTop];
                
                cell.accessoryView = [DTCustomColoredAccessory accessoryWithColor:[UIColor grayColor] type:DTCustomColoredAccessoryTypeUp];
            }
        } else {
        }
        
    } else {
    }
}

- (void) selectChild : (id) sender {
	
	UIButton *btn_selectChild = (UIButton *) sender;
	
	int rowIndex = [[btn_selectChild superview] tag];
	int secIndex = [[[btn_selectChild superview] superview] tag];
	NSMutableDictionary *dictFather = [[self.dict_scheduleData objectForKey:@"buddies"] objectAtIndex:secIndex];
	
	if (rowIndex) {
		
		rowIndex -= 1;
		NSMutableDictionary *dictSon = [[dictFather objectForKey:@"Tykes"] objectAtIndex:rowIndex];
		if ([[dictSon objectForKey:@"selected"] intValue]) {
			[dictSon setObject:@"0" forKey:@"selected"];
			
			BOOL selected = NO;
			for (NSDictionary *dictTy in [dictFather objectForKey:@"Tykes"]) {
				if ([[dictTy objectForKey:@"selected"] intValue]) {
					selected = YES;
					break;
				}
			}
			
			if (selected) {
				[dictFather setObject:@"1" forKey:@"selected"];
			}else {
				[dictFather setObject:@"0" forKey:@"selected"];
			}
		}else {
			[dictSon setObject:@"1" forKey:@"selected"];
			[dictFather setObject:@"1" forKey:@"selected"];
		}
	}else {
		
		if ([[dictFather objectForKey:@"selected"] intValue]) {
			
			for (NSMutableDictionary *dictTyke in [dictFather objectForKey:@"Tykes"]) {
				[dictTyke setObject:@"0" forKey:@"selected"];
			}
			
			[dictFather setObject:@"0" forKey:@"selected"];
		}else {
			
			[dictFather setObject:@"1" forKey:@"selected"];
			for (NSMutableDictionary *dictTyke in [dictFather objectForKey:@"Tykes"]) {
				[dictTyke setObject:@"1" forKey:@"selected"];
			}
		}
	}

	[theTableView reloadData];
}

#pragma mark - API Response 

- (void) sortBuddies {
	
	arr_wannaHang = [NSMutableArray new];
	arr_inKnit = [NSMutableArray new];
	
	for (NSMutableDictionary *dictParent in [self.dict_scheduleData objectForKey:@"buddies"]) {
		
		BOOL wannaHang = NO;
		for (NSDictionary *dictTyke in [dictParent objectForKey:@"Tykes"]) {
			if ([[dictTyke objectForKey:@"WannaHang"] isEqualToString:@"t"]) {
				[arr_wannaHang addObject:[dictParent objectForKey:@"ParentUserTblPk"]];
				wannaHang = YES;
				break;
			}
		}
		
		if (!wannaHang) {
			[arr_inKnit addObject:[dictParent objectForKey:@"ParentUserTblPk"]];
			[dictParent setObject:@"0" forKey:@"WannaHang"];
		}else {
			[dictParent setObject:@"1" forKey:@"WannaHang"];
		}
	}
	
	NSSortDescriptor *dateSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"WannaHang" ascending:NO selector:@selector(compare:)] autorelease];
	[[self.dict_scheduleData objectForKey:@"buddies"] sortUsingDescriptors:[NSArray arrayWithObjects:dateSortDescriptor, nil]];
}

- (void) getBuddiesResp : (NSData*)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	[self.dict_scheduleData removeObjectForKey:@"buddies"];
	if ([[[response objectForKey:@"response"] objectForKey:@"Buddies"] count]) {
		NSMutableArray *arrRes = [[response objectForKey:@"response"] objectForKey:@"Buddies"];
		for (NSMutableDictionary *dict1 in arrRes) {
			if ([[dict1 objectForKey:@"ParentUserTblPk"] isEqualToString:self.selectedBuddy]) {
				[dict1 setObject:@"1" forKey:@"selected"];
				NSMutableArray *arr_selectedTykes = [dict1 objectForKey:@"Tykes"];
				for (NSMutableDictionary *dict2 in arr_selectedTykes) {
					[dict2 setObject:@"1" forKey:@"selected"];
				}
				break;
			}
		}
		[self.dict_scheduleData setObject:arrRes forKey:@"buddies"];
		
		[self sortBuddies];
		lbl_errorMsg.hidden = YES;
		theTableView.hidden = NO;
		[self.theTableView reloadData];
	} else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error!"
													   message:@"You don't have any friends in your knit. To get more out of TykeKnit, invite your friends to join your knit."
													  delegate:self 
											 cancelButtonTitle:@"Skip" 
                                             otherButtonTitles:@"Add Now", nil];
		[alert setTag:300];
		[alert show];
		[alert release];
		
		lbl_errorMsg.hidden = NO;
		theTableView.hidden = YES;
	}

	[DELEGATE removeLoadingView:self.vi_main];
	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 300) {
		
		if (buttonIndex == 0) {
			[self popViewController];
		}else {
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			
			AddFriendsViewController *frdsVC = [[AddFriendsViewController alloc] initWithNibName:@"AddFriendsViewController" bundle:nil ];
			frdsVC.prevContImage = currentImage;
			[self.navigationController pushViewController:frdsVC animated:NO];
			[frdsVC release];
		}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
	
    [super viewDidUnload];
}

- (void)dealloc {
    [expandedSections release];
    [theTableView release];

    [dict_scheduleData release];;
    [api_tyke release];
    [child_id release];
    [super dealloc];
}


@end
