//
//  DashboardViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 23/11/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "DashboardViewController.h"
#import "InvitersProfileViewController.h"
#import "PlaydateScheduleViewController.h"
#import "TableCellImageView.h"
#import "PlaydateNotificationViewController.h"
#import "MyFriendsViewController.h"
#import "MessagesViewController.h"
#import "Global.h"
#import "JSON.h"
#import "PastPlaydatesViewController.h"
#import "PlaydateDetailViewController.h"

@implementation DashboardViewController
@synthesize theTableView,dict_data,api_tyke,profilePic;

#define blueTextColor [UIColor colorWithRed:0.263 green:0.302 blue:0.392 alpha:1.0]
#define lightBlueTextColor [UIColor colorWithRed:0.204 green:0.318 blue:0.525 alpha:1.0]
#define tableBackgroundColor [UIColor colorWithRed:0.875 green:0.906 blue:0.918 alpha:1.0]
#define cellBackgroundColor [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0]

- (void) viewWillAppear:(BOOL)animated {

	if ([[[DELEGATE window] subviews] containsObject:[DELEGATE nav_wannaHangBar].view]) {
		[[DELEGATE nav_wannaHangBar].view removeFromSuperview];
	}

	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_dashBoard1 aboveSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_dashBoard2 belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_dashBoard3 belowSubview:[DELEGATE vi_sideView].img_back];
    [[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_home belowSubview:[DELEGATE vi_sideView].img_back];


	[self.theTableView reloadData];
	if ([[self.dict_data objectForKey:@"Activities"] count] == 0) {
        noUpcomingPlaydates = YES;
	}

	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke getUpcomingPlaydates:@"20" frowRow:@"0" wantPastPlaydates:@"0"];

	[super viewWillAppear:animated];
}


- (void) morePlaydatesClicked : (id) sender {
	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke getUpcomingPlaydates:@"20" frowRow:[NSString stringWithFormat:@"%d",[[self.dict_data objectForKey:@"Activities"] count]] wantPastPlaydates:@"0"];

}

- (void) reloadData {
	[self.dict_data removeAllObjects];
	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke getUpcomingPlaydates:@"20" frowRow:@"0" wantPastPlaydates:@"0"];
}

- (void) viewDidLoad {
	

	self.theTableView.backgroundColor = [UIColor clearColor];
    
	//shadow for Navigationbar
	
	CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.5f].CGColor;
	CGColorRef lightColor = [UIColor clearColor].CGColor;
	
	CAGradientLayer *newShadow = [[[CAGradientLayer alloc] init] autorelease];
	newShadow.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.width, 7);
	newShadow.colors = [NSArray arrayWithObjects:(id)darkColor, (id)lightColor, nil];
	[self.navigationController.navigationBar.layer addSublayer:newShadow];	

	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Dashboard"];
	[self.theTableView setBackgroundColor:tableBackgroundColor];
	if (!api_tyke) {
		api_tyke = [[TykeKnitApi alloc]init];
		api_tyke.delegate = self;
	}
    
    noUpcomingPlaydates = YES;
	self.dict_data = [[NSMutableDictionary alloc] init];


	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"Playdate RSVP Changed" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadProfilePic:) name:PROFILE_PIC_CHANGED object:nil];

	[super viewDidLoad];
}

- (void) reloadProfilePic:(NSNotificationCenter *)notify {
	[self.profilePic setImageUrl:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"picURL"]];
}

#pragma mark -
#pragma mark UISearchBarDelagate Methods

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar1 {
	[self cancelSearch];
} 

- (void) cancelSearch {
	
	[self.vi_main endEditing:YES];
	if (searchBar.superview) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:Trans_Duration];
		searchBar.frame = CGRectMake( 0, -44, 280, 44);
		[UIView commitAnimations];
		
		CGRect prevRect = self.theTableView.frame;
		prevRect.origin.y = 0;
		prevRect.size.height += 44;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:Trans_Duration];
		self.theTableView.frame = prevRect;
		[UIView commitAnimations];
		
		[searchBar setShowsCancelButton:NO animated:YES];
		[searchBar performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:Trans_Duration];
	}
}


#pragma mark -
#pragma mark RightSideViewDelegate

- (void) buttonClickedNamed : (NSString*) name {
	
	if ([name isEqualToString:@"Playdates"]) {
		for (UIViewController *viewCont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
		[self.navigationController popToRootViewControllerAnimated:NO];
		[[[self.navigationController viewControllers] objectAtIndex:0] viewWillAppear:NO];
	}else if([name isEqualToString:@"Messages"]) {
		for (UIViewController *viewCont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
		MessagesViewController *messages = [[MessagesViewController alloc] initWithNibName:@"MessagesViewController" bundle:nil];
		[self.navigationController pushViewController:messages animated:NO];
		[messages release];
	}else if([name isEqualToString:@"Friends"]) {
		
		for (UIViewController *viewCont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
		
		MyFriendsViewController *friends = [[MyFriendsViewController alloc] initWithNibName:@"MyFriendsViewController" bundle:nil];
		[self.navigationController pushViewController:friends animated:NO];
		[friends release];
	}
}	

-(BOOL) isWannaHangHighlighted {
	return YES;
}

#pragma mark -
#pragma mark UITableViewDelagate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	[self cancelSearch];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 1 && [[self.dict_data objectForKey:@"Activities"] count]) {
	return 30;
	}
	return 0;
}
 
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

	if (noUpcomingPlaydates) {
        return nil;
    }

    UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 50)] autorelease];
    if(section == 1 && [[self.dict_data objectForKey:@"Activities"] count]){
        
        UILabel *headerName = [[UILabel alloc] initWithFrame:CGRectMake(30, 3, 160, 20)];
        headerName.textAlignment = UITextAlignmentLeft;
        headerName.textColor = blueTextColor;
        headerName.text = @"Upcoming Playdates";
        [headerName setFont:[UIFont fontWithName:@"helvetica Neue" size:16]];
        [headerName setFont:[UIFont boldSystemFontOfSize:16]];
        headerName.shadowOffset = CGSizeMake(0, 1);
        headerName.shadowColor = [UIColor whiteColor]; 
        headerName.backgroundColor = [UIColor clearColor];
        [vi addSubview:headerName];
        [headerName release];
    }
    return vi;

}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (noUpcomingPlaydates) {
        return 0;
    }
    
	if (section == 1 && [[self.dict_data objectForKey:@"Activities"] count] > 19) {
		return 30;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (noUpcomingPlaydates) {
        return nil;
    }
    
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 20)] autorelease];
	if(section == 1 && [[self.dict_data objectForKey:@"Activities"] count] > 19){
		
		UIButton *headerName = [UIButton buttonWithType:UIButtonTypeCustom];
		[headerName setFrame:CGRectMake(0, 7, 260, 20)];
		[headerName addTarget:self action:@selector(morePlaydatesClicked:) forControlEvents:UIControlEventTouchUpInside];
		headerName.titleLabel.textAlignment = UITextAlignmentCenter;
		[headerName setTitle:@"More Upcoming Playdates" forState:UIControlStateNormal];
		[headerName setTitleColor:[UIColor colorWithRed:0.161 green:0.235 blue:0.404 alpha:1] forState:UIControlStateNormal];
		[headerName.titleLabel setFont:[UIFont fontWithName:@"helvetica Neue" size:16]];
		[headerName.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
		headerName.backgroundColor = [UIColor clearColor];
		[vi addSubview:headerName];
	}
	return vi;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	//int rowInd = [indexPath row];
	if (indexPath.section == 0) {
		NSString *userInfoCell = @"userInfoCell";
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.backgroundColor = cellBackgroundColor;
			
			self.profilePic = [[TableCellImageView alloc] initWithFrame:CGRectMake(15.0, 5, 50, 50)];
			self.profilePic.defaultImage = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
			self.profilePic.tag = 1;
			[cell.contentView addSubview:self.profilePic];
			[self.profilePic release];
			
			UILabel *lbl_name = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, 165, 20)];
			lbl_name.tag = 2;
			lbl_name.backgroundColor = [UIColor clearColor];
			lbl_name.numberOfLines = 0;
			lbl_name.textAlignment = UITextAlignmentLeft;
			lbl_name.textColor = blueTextColor;
			lbl_name.font = [UIFont boldSystemFontOfSize:16];
            lbl_name.shadowColor = [UIColor whiteColor];
            lbl_name.shadowOffset = CGSizeMake(0, 1);
			[cell.contentView addSubview:lbl_name];
			[lbl_name release];
			
			UIImage *countHolder = [[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"indicator_blue.png")] stretchableImageWithLeftCapWidth:8.0 topCapHeight:8.0];
            UIImageView *countView = [[UIImageView alloc] initWithImage:countHolder];
            countView.frame = CGRectMake(75.0, 30.0, 25.0, 22.0);
            countView.tag = 5;
            countView.clipsToBounds = YES;
            
            UILabel *countLabel = [[UILabel alloc] initWithFrame:countView.bounds];
            countLabel.backgroundColor = [UIColor clearColor];
            countLabel.textColor = [UIColor whiteColor];
            [countLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
            [countLabel setTextAlignment:UITextAlignmentCenter];
            countLabel.tag = 3;
            [countLabel setAdjustsFontSizeToFitWidth:YES];
            [countLabel setMinimumFontSize:6.0];
            [countLabel setLineBreakMode:UILineBreakModeClip];
            [countLabel setText:@"0"];
            [countView addSubview:countLabel];
            [countLabel release];
            
            [cell.contentView addSubview:countView];
            [countView release];
//			UIImage *lbl_noOfPlaydates = [[UILabel alloc]initWithFrame:CGRectMake(85.0, 25, 100, 20)];
//			lbl_noOfPlaydates.tag = 3;
//			lbl_noOfPlaydates.backgroundColor = [UIColor clearColor];
//			lbl_noOfPlaydates.numberOfLines = 0;
//			lbl_noOfPlaydates.textAlignment = UITextAlignmentLeft;
//			lbl_noOfPlaydates.textColor = [UIColor lightGrayColor];
//			lbl_noOfPlaydates.font = [UIFont boldSystemFontOfSize:12];
//			[cell.contentView addSubview:lbl_noOfPlaydates];
//			[lbl_noOfPlaydates release];
			
			UILabel *lbl_noOfMessages = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 30, 120.0, 20.0)];
			lbl_noOfMessages.tag = 4;
			lbl_noOfMessages.backgroundColor = [UIColor clearColor];
			lbl_noOfMessages.numberOfLines = 0;
			lbl_noOfMessages.textColor = [UIColor colorWithWhite:0.0 alpha:0.50];
            lbl_noOfMessages.text = @"Unread Messages";
			lbl_noOfMessages.font = [UIFont systemFontOfSize:12];
			[cell.contentView addSubview:lbl_noOfMessages];
			[lbl_noOfMessages release];
		}
		
		TableCellImageView *img_view = (TableCellImageView *)[cell.contentView viewWithTag:1];
		UILabel *lbl_name = (UILabel *)[cell.contentView viewWithTag:2];
		UILabel *countLabel = (UILabel *)[cell.contentView viewWithTag:3];
        UIImageView *countView = (UIImageView *)[cell.contentView viewWithTag:5];        
        UILabel *lbl_noOfMessages = (UILabel *)[cell.contentView viewWithTag:4];
        
		
		if ([[self.dict_data objectForKey:@"messagesCount"] intValue] > 0) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
		
		
		
		[img_view setImageUrl:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"picURL"]];

		if ([[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"fname"] && [[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"lname"]) {
			lbl_name.text = [[NSString stringWithFormat:@"%@ %@",[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"fname"],[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"lname"]] capitalizedString]; 
		}
		if ([self.dict_data objectForKey:@"messagesCount"]) {
			countLabel.text = [NSString stringWithFormat:@"%@",[self.dict_data objectForKey:@"messagesCount"]];

//            countLabel.text = @"0";
            [countLabel sizeToFit];
            
            CGRect countViewFrame = countView.frame;
            countViewFrame.size.width = countLabel.frame.size.width + 13.0;
            countViewFrame.size.height = countLabel.frame.size.height + 8.0;            
            countView.frame = countViewFrame;
            
            countLabel.center = CGPointMake([countView convertPoint:countView.center fromView:[countView superview]].x, [countView convertPoint:countView.center fromView:[countView superview]].y - 2.0);
            
            CGRect frame = lbl_noOfMessages.frame;
            frame.origin.x = countView.frame.origin.x + countView.frame.size.width + 3.0;
            lbl_noOfMessages.frame = frame;
            
		}
		return cell;
		
	}else if (indexPath.section == 1) {
        
        if (noUpcomingPlaydates) {
            NSString *userInfoCell = @"noUpcomingPlaydatesCell";
            cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
            if (cell == nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.backgroundColor = cellBackgroundColor;	
                cell.textLabel.text = @"No Upcoming Playdates";
                cell.textLabel.font = [UIFont systemFontOfSize:16];
                cell.textLabel.textAlignment = UITextAlignmentRight;
                cell.textLabel.textColor =  blueTextColor;
            }
            
            return cell;
        }
        
		NSString *userInfoCell = @"playdatesCell";
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.backgroundColor = cellBackgroundColor;
			
			UIImageView *img_date = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 45)];
			img_date.tag = 11;
			img_date.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"dashboard_calenderImage")];
			img_date.contentMode = UIViewContentModeScaleAspectFill;
			img_date.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:img_date];
			[img_date release];
			
			UILabel *lbl_month = [[UILabel alloc]initWithFrame:CGRectMake(15, 23, 38, 12)];
			[lbl_month setTag:12];
			[lbl_month setTextAlignment:UITextAlignmentCenter];
			[lbl_month setFont:[UIFont boldSystemFontOfSize:7]];
			[lbl_month setTextColor:[UIColor whiteColor]];
			[lbl_month setBackgroundColor:[UIColor clearColor]];
			[cell.contentView addSubview:lbl_month];
            [lbl_month release];

			UILabel *lbl_day = [[UILabel alloc]initWithFrame:CGRectMake(25, 31, 20, 20)];
			[lbl_day setTag:13];
			[lbl_day setTextColor:[UIColor whiteColor]];
			[lbl_day setFont:[UIFont boldSystemFontOfSize:16]];
			[lbl_day setBackgroundColor:[UIColor clearColor]];
			[cell.contentView addSubview:lbl_day];
			[lbl_day release];
								  
			UILabel *lbl_invitees = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, 170, 20)];
			lbl_invitees.tag = 14;
			lbl_invitees.backgroundColor = [UIColor clearColor];
			lbl_invitees.numberOfLines = 0;
			lbl_invitees.textColor = lightBlueTextColor;
			lbl_invitees.textAlignment = UITextAlignmentLeft;
			lbl_invitees.font = [UIFont boldSystemFontOfSize:15];
            lbl_invitees.shadowColor = [UIColor whiteColor];
            lbl_invitees.shadowOffset = CGSizeMake(0, 1);
			[cell.contentView addSubview:lbl_invitees];
			[lbl_invitees release];
			
			UILabel *lbl_organiser = [[UILabel alloc]initWithFrame:CGRectMake(75, 28, 150, 20)];
			lbl_organiser.tag = 15;
			lbl_organiser.backgroundColor = [UIColor clearColor];
			lbl_organiser.numberOfLines = 0;
			lbl_organiser.text = @"Organizer:";
			lbl_organiser.textAlignment = UITextAlignmentLeft;
			lbl_organiser.textColor = [UIColor grayColor];
			lbl_organiser.font = [UIFont boldSystemFontOfSize:12];
			[cell.contentView addSubview:lbl_organiser];
            [lbl_organiser sizeToFit];
			[lbl_organiser release];
            
            UILabel *lbl_organiser_value = [[UILabel alloc]initWithFrame:CGRectMake(75 + lbl_organiser.frame.size.width + 2,
                                                                                    lbl_organiser.frame.origin.y , 
                                                                                    100, 
                                                                                    lbl_organiser.frame.size.height)];
			lbl_organiser_value.tag = 17;
			lbl_organiser_value.backgroundColor = cellBackgroundColor;
			lbl_organiser_value.numberOfLines = 1;
			lbl_organiser_value.textAlignment = UITextAlignmentLeft;
			lbl_organiser_value.textColor = lightBlueTextColor;
			lbl_organiser_value.font = [UIFont boldSystemFontOfSize:12];
			[cell.contentView addSubview:lbl_organiser_value];
			[lbl_organiser_value release];

			UILabel *lbl_location = [[UILabel alloc] initWithFrame:CGRectMake(75, 38, 150,23)];
			lbl_location.tag = 16;
			lbl_location.text =@"location : ";
			lbl_location.backgroundColor = [UIColor clearColor];
			lbl_location.numberOfLines = 0;
			lbl_location.textColor = [UIColor darkGrayColor];
			lbl_location.font = [UIFont systemFontOfSize:12];
			[cell.contentView addSubview:lbl_location];
			[lbl_location release];
			 
		}
//		UIImageView *img_date = (UIImageView *)[cell viewWithTag:11];
		UILabel *lbl_month = (UILabel *)[cell.contentView viewWithTag:12];
		UILabel *lbl_day = (UILabel *)[cell.contentView viewWithTag:13];
		UILabel *lbl_invities = (UILabel *)[cell viewWithTag:14];
		UILabel *lbl_organiser_value = (UILabel *)[cell viewWithTag:17];        
		UILabel *lbl_location = (UILabel*)[cell viewWithTag:16];
		
//		img_view.image = [UIImage imageNamed:@"userimage.png"];
		NSMutableDictionary *dict = [[self.dict_data objectForKey:@"Activities"] objectAtIndex:indexPath.row];		
		if ([dict objectForKey:@"txtPlaydateDate"]) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
			[formatter setDateFormat:@"yyyy-MM-dd"];
			NSDate *dt = [formatter dateFromString:[dict objectForKey:@"txtPlaydateDate"]];
			[formatter setDateFormat:@"MMMM"];
			NSString *str_month = [formatter stringFromDate:dt];
			[formatter setDateFormat:@"dd"];
			NSString *str_date = [formatter stringFromDate:dt];
			lbl_month.text = str_month;
			lbl_day.text = str_date;
			[formatter release];
		}
		
		NSString *str_invities = @"";
			if ([dict objectForKey:@"Tykes"]) {
				for (NSString *str in [dict objectForKey:@"Tykes"]) {
					if ([str_invities length]) {
						str_invities = [str_invities stringByAppendingFormat:@", %@",[str capitalizedString]];
					}else {
						str_invities = [str_invities stringByAppendingFormat:@"%@",[str capitalizedString]];
					}
				}
			}
		lbl_invities.text = str_invities;
		
		if ([dict objectForKey:@"txtOrganiserName"]) {
            lbl_organiser_value.text = [[@"" stringByAppendingFormat:@"%@",[dict objectForKey:@"txtOrganiserName"]] capitalizedString];
		}
		
		if ([dict objectForKey:@"txtPlaydateLocation"]) {
			lbl_location.text = [dict objectForKey:@"txtPlaydateLocation"];
		}

		return cell;
/*        
	} else if (noUpcomingPlaydates) {
        if (indexPath.section == 2) {
            NSString *userInfoCell = @"placeholder";
            cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
            if (cell == nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:userInfoCell] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.backgroundColor = [UIColor clearColor];
                cell.textLabel.font = [UIFont systemFontOfSize:16];
                cell.textLabel.textAlignment = UITextAlignmentRight;
                cell.textLabel.textColor =  blueTextColor;
                
                UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(-20, -10, 320.0, 160.0)];
                backgroundView.backgroundColor = tableBackgroundColor;
                [cell.contentView addSubview:backgroundView];
                
                UILabel *heading = [[UILabel alloc] initWithFrame:CGRectMake(35.0, 20, 280.0, 30.0)];
                [heading setText:@"Looking a little light?"];
                [heading setShadowColor:[UIColor whiteColor]];
                [heading setShadowOffset:CGSizeMake(0, 1)];
                [heading setFont:[UIFont boldSystemFontOfSize:16]];
                [heading setBackgroundColor:tableBackgroundColor];
                [heading setTextColor:blueTextColor];
                [backgroundView addSubview:heading];
                [heading release];
                
                UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(35.0, 50.0, 220.0, 90.0)];
                [content setText:@"Build your Knit, plan a playdate and explore the true potential of TykeKnit. And before you know it, this dashboard will be full of fun-filled activities for you and your tyke(s). Ready to plan a playdate?"];
                [content setShadowColor:[UIColor whiteColor]];
                [content setLineBreakMode:UILineBreakModeWordWrap];
                [content setNumberOfLines:0];
                [content setShadowOffset:CGSizeMake(0, 1)];
                [content setFont:[UIFont systemFontOfSize:12]];
                [content setBackgroundColor:tableBackgroundColor];
                [content setTextColor:blueTextColor];
                [backgroundView addSubview:content];
                [content release];
                
                UILabel *link = [[UILabel alloc] initWithFrame:CGRectMake(90.0, 123.0, 60.0, 20.0)];
                [link setText:@"Click here"];
                [link setShadowColor:[UIColor whiteColor]];
                [link setShadowOffset:CGSizeMake(0, 1)];
                [link setFont:[UIFont boldSystemFontOfSize:12]];
                [link setBackgroundColor:tableBackgroundColor];
                [link setTextColor:blueTextColor];
                [backgroundView addSubview:link];
                [link release];
                
                [backgroundView release];
                
            }
            return cell;
        } else if (indexPath.section == 3) {
            NSString *userInfoCell = @"addFriendsCell";
            cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
            if (cell == nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.backgroundColor = cellBackgroundColor;	
                cell.textLabel.text = @"My Friends";
                cell.textLabel.font = [UIFont systemFontOfSize:16];
                cell.textLabel.textAlignment = UITextAlignmentRight;
                cell.textLabel.textColor =  blueTextColor;
            }
            
            return cell;
        } else if (indexPath.section == 4) {
            NSString *userInfoCell = @"pastPlaydatesCell";
            cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
            if (cell == nil){
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.backgroundColor = cellBackgroundColor;	
                cell.textLabel.text = @"Past Playdates";
                cell.textLabel.font = [UIFont systemFontOfSize:16];
                cell.textLabel.textAlignment = UITextAlignmentRight;
                cell.textLabel.textColor =  blueTextColor;
            }
            
            return cell;
        }

	}
 */
    } else if (indexPath.section == 2) {
        NSString *userInfoCell = @"addFriendsCell";
        cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor = cellBackgroundColor;	
            cell.textLabel.text = @"My Friends";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textAlignment = UITextAlignmentRight;
            cell.textLabel.textColor =  blueTextColor;
        }
        
        return cell;
    } else if (indexPath.section == 3) {
        NSString *userInfoCell = @"pastPlaydatesCell";
        cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
        if (cell == nil){
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.backgroundColor = cellBackgroundColor;	
            cell.textLabel.text = @"Past Playdates";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textAlignment = UITextAlignmentRight;
            cell.textLabel.textColor =  blueTextColor;
        }
        
        return cell;
    }    
	return nil;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
/*
	if (noUpcomingPlaydates) {
        return 5;
    }
*/ 
	return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 60.0;
    } else if (noUpcomingPlaydates) {
        return 44.0;
    }
    else {
        if (indexPath.section == 2 || indexPath.section == 3) {
            return 44.0;
        }
    }

	return 70;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    
    if (noUpcomingPlaydates) {
        return 1;
    } else {
        if (section == 2 || section == 3) {
            return 1;
        }
    }

    return [[self.dict_data objectForKey:@"Activities"] count];        

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.section == 0 && [[self.dict_data objectForKey:@"messagesCount"] intValue] > 0) {
		UIButton *rightside_btnMessage = (UIButton *)DELEGATE.vi_sideView.btn_dashBoard2;
		[rightside_btnMessage sendActionsForControlEvents:UIControlEventTouchUpInside];
	}

	if (noUpcomingPlaydates) {
 /*       
        if (indexPath.section == 2) {
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			PlaydateScheduleViewController *playdateScheduleViewController = [[PlaydateScheduleViewController alloc]initWithNibName:@"PlaydateScheduleViewController" bundle:nil];
			playdateScheduleViewController.prevContImage = currentImage;
			//	playdateScheduleViewController.arr_invities = self.arr_invities;
			[self.navigationController pushViewController:playdateScheduleViewController animated:NO];
			[playdateScheduleViewController release];
        }
        if (indexPath.section == 2) {
            for (UIViewController *viewCont in [self.navigationController viewControllers]) {
                [self.navigationController popViewControllerAnimated:NO];
            }
            
            MyFriendsViewController *friends = [[MyFriendsViewController alloc] initWithNibName:@"MyFriendsViewController" bundle:nil];
            [self.navigationController pushViewController:friends animated:NO];
            [friends release];
        }

        if (indexPath.section == 3) {
            UIImage *currentImage = [self captureScreen];
            [self pushingViewController:currentImage];
            
            PastPlaydatesViewController *pastPlaydatesViewController = [[PastPlaydatesViewController alloc]initWithNibName:@"PastPlaydatesViewController" bundle:nil];
            pastPlaydatesViewController.prevContImage = currentImage;
            [self.navigationController pushViewController:pastPlaydatesViewController animated:NO];
            [pastPlaydatesViewController release];
        }
*/
    } else {
        if (indexPath.section == 1) {
            UIImage *currentImage = [self captureScreen];
            [self pushingViewController:currentImage];
            PlaydateDetailViewController *details = [[PlaydateDetailViewController alloc]initWithNibName:@"PlaydateDetailViewController" bundle:nil];
            details.prevContImage = currentImage;
            details.playdate_id = [[[self.dict_data objectForKey:@"Activities"] objectAtIndex:indexPath.row] objectForKey:@"txtPid"];
            [self.navigationController pushViewController:details animated:NO];
            [details release];
        }

    }

    if (indexPath.section == 2) {
        for (UIViewController *viewCont in [self.navigationController viewControllers]) {
            [self.navigationController popViewControllerAnimated:NO];
        }
        
        MyFriendsViewController *friends = [[MyFriendsViewController alloc] initWithNibName:@"MyFriendsViewController" bundle:nil];
        [self.navigationController pushViewController:friends animated:NO];
        [friends release];
    }
    
    if (indexPath.section == 3) {
        UIImage *currentImage = [self captureScreen];
        [self pushingViewController:currentImage];
        
        PastPlaydatesViewController *pastPlaydatesViewController = [[PastPlaydatesViewController alloc]initWithNibName:@"PastPlaydatesViewController" bundle:nil];
        pastPlaydatesViewController.prevContImage = currentImage;
        [self.navigationController pushViewController:pastPlaydatesViewController animated:NO];
        [pastPlaydatesViewController release];
    }
    
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) upcomingPlaydatesResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		if ([[response objectForKey:@"response"] objectForKey:@"Activities"]) {
			noUpcomingPlaydates = NO;
		}else {
			noUpcomingPlaydates = YES;
		}
		self.dict_data = [response objectForKey:@"response"];
	}else {
		noUpcomingPlaydates = YES;
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
															message:@"No More Upcoming Playdates."// MSG_ERROR_VALID_REGISTER4
														   delegate:nil
												  cancelButtonTitle:@"Ok" 
												  otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
/*
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		if ([[self.dict_data objectForKey:@"Activities"] count] && [[response objectForKey:@"response"] objectForKey:@"Activities"]) {
			[[self.dict_data objectForKey:@"Activities"] addObjectsFromArray:[[response objectForKey:@"response"] objectForKey:@"Activities"]];
            noUpcomingPlaydates = NO;
		}else if (![[self.dict_data allKeys] count]) {
			if ([[response objectForKey:@"response"] objectForKey:@"Activities"]) {
				noUpcomingPlaydates = NO;
			}else {
				noUpcomingPlaydates = YES;
			}
			self.dict_data = [response objectForKey:@"response"];
//            noUpcomingPlaydates = YES;            
		} else {
            noUpcomingPlaydates = YES;
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
															   message:@"No More Upcoming Playdates."// MSG_ERROR_VALID_REGISTER4
															  delegate:nil
													 cancelButtonTitle:@"Ok" 
													 otherButtonTitles:nil];
			[alertView show];
			[alertView release];
		}
 */
		[self.theTableView reloadData];
}


- (void) getInvitationsResponse : (NSData *)data {
//	NSDictionary *response = [[data stringValue] JSONValue];
}
- (void) getMessagesResponse : (NSData *)data {
//	NSDictionary *response = [[data stringValue] JSONValue];
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

- (void)dealloc {
	[self.dict_data release];
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}

@end
