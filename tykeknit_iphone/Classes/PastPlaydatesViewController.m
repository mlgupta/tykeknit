//
//  PastPlaydatesViewController.m
//  TykeKnit
//
//  Created by Ver on 08/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PastPlaydatesViewController.h"
#import "PastPlaydateDetailsViewController.h"
#import "JSON.h"


@implementation PastPlaydatesViewController
@synthesize theTableView,api_tyke,dict_data;


- (void) backPressed:(id) sender {
	[self popViewController];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	UIButton *btn = [DELEGATE getBackBarButton];
	[btn addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Playdate"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];

	self.dict_data = [[NSMutableDictionary alloc]init];
	if (!api_tyke) {
		api_tyke = [[TykeKnitApi alloc]init];
		api_tyke.delegate = self;
	}
	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke getUpcomingPlaydates:@"100" frowRow:@"0" wantPastPlaydates:@"1"];
	
    [super viewDidLoad];
}




- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	return 70;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if ([[self.dict_data objectForKey:@"Activities"] count]) {
		return [[self.dict_data objectForKey:@"Activities"] count];
	}
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	//int rowInd = [indexPath row];
		NSString *userInfoCell = @"userInfoCell";
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.backgroundColor = [UIColor colorWithRed:0.933 green:0.949 blue:0.961 alpha:1.0];
			
			UIImageView *img_date = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 40, 45)];
			img_date.tag = 11;
			img_date.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"dashboard_calenderImage")];
			img_date.contentMode = UIViewContentModeScaleAspectFill;
			img_date.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:img_date];
			[img_date release];
			
			UILabel *lbl_month = [[UILabel alloc]initWithFrame:CGRectMake(15, 25, 38, 12)];
			[lbl_month setTag:12];
			[lbl_month setTextAlignment:UITextAlignmentCenter];
			[lbl_month setFont:[UIFont boldSystemFontOfSize:7]];
			[lbl_month setTextColor:[UIColor whiteColor]];
			[lbl_month setBackgroundColor:[UIColor clearColor]];
			[cell.contentView addSubview:lbl_month];
            [lbl_month release];
			
			UILabel *lbl_day = [[UILabel alloc]initWithFrame:CGRectMake(27, 33, 20, 20)];
			[lbl_day setTag:13];
			[lbl_day setTextColor:[UIColor whiteColor]];
			[lbl_day setFont:[UIFont boldSystemFontOfSize:16]];
			[lbl_day setBackgroundColor:[UIColor clearColor]];
			[cell.contentView addSubview:lbl_day];
			[lbl_day release];
			
			UILabel *lbl_invitees = [[UILabel alloc]initWithFrame:CGRectMake(75, 10, 190, 20)];
			lbl_invitees.tag = 14;
			lbl_invitees.backgroundColor = [UIColor clearColor];
			lbl_invitees.text = @"invitees : ";
			lbl_invitees.numberOfLines = 0;
			lbl_invitees.textColor = [UIColor colorWithRed:0.161 green:0.235 blue:0.404 alpha:1];
			lbl_invitees.textAlignment = UITextAlignmentLeft;
			lbl_invitees.font = [UIFont boldSystemFontOfSize:13];
			[cell.contentView addSubview:lbl_invitees];
			[lbl_invitees release];
			
			UILabel *lbl_organiser = [[UILabel alloc]initWithFrame:CGRectMake(75, 30, 180, 20)];
			lbl_organiser.tag = 15;
			lbl_organiser.backgroundColor = [UIColor clearColor];
			lbl_organiser.numberOfLines = 0;
			lbl_organiser.text = @"Organizer : ";
			lbl_organiser.textAlignment = UITextAlignmentLeft;
			lbl_organiser.textColor = [UIColor lightGrayColor];
			lbl_organiser.font = [UIFont systemFontOfSize:12];
			[cell.contentView addSubview:lbl_organiser];
			[lbl_organiser release];
			
			UILabel *lbl_location = [[UILabel alloc] initWithFrame:CGRectMake(75, 45, 150,20)];
			lbl_location.tag = 16;
			lbl_location.text =@"location : ";
			lbl_location.backgroundColor = [UIColor clearColor];
			lbl_location.textColor = [UIColor blackColor];
			lbl_location.numberOfLines = 0;
			lbl_location.textColor = [UIColor grayColor];
			lbl_location.font = [UIFont boldSystemFontOfSize:12];
			[cell.contentView addSubview:lbl_location];
			[lbl_location release];
			
		}
		UIImageView *img_date = (UIImageView *)[cell viewWithTag:11];
		UILabel *lbl_month = (UILabel *)[cell.contentView viewWithTag:12];
		UILabel *lbl_day = (UILabel *)[cell.contentView viewWithTag:13];
		UILabel *lbl_invities = (UILabel *)[cell viewWithTag:14];
		UILabel *lbl_organiser = (UILabel *)[cell viewWithTag:15];
		UILabel *lbl_location = (UILabel*)[cell viewWithTag:16];
	
		//		img_view.image = [UIImage imageNamed:@"userimage.png"];
//		if (indexPath.row == [[self.dict_data objectForKey:@"Activities"] count] && [[self.dict_data objectForKey:@"Activities"] count] > 10) {
//			cell.textLabel.text =@"More Playdates";
//			return cell;
//		}
	if (![[self.dict_data objectForKey:@"Activities"] count]) {
		cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
		cell.textLabel.textColor = [UIColor grayColor];
		cell.textLabel.text = @"You do not have any past playdates";
		lbl_invities.text = @"";
		lbl_organiser.text = @"";
		lbl_location.text = @"";
		img_date.hidden = YES;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
		return cell;
	}
		img_date.hidden = NO;
		cell.textLabel.text = @"";
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
	
		NSString *str_invities = [[[NSString alloc]init] autorelease];
		if ([dict objectForKey:@"Tykes"]) {
			for (NSString *str in [dict objectForKey:@"Tykes"]) {
				if ([str_invities length]) {
					str_invities = [str_invities stringByAppendingFormat:@", %@",str];
				}else {
					str_invities = [str_invities stringByAppendingFormat:@"%@",str];
				}
			}
		}
	
		lbl_invities.text = str_invities;
		
		if ([dict objectForKey:@"txtOrganiserName"]) {
			lbl_organiser.text = [lbl_organiser.text stringByAppendingFormat:@"%@",[dict objectForKey:@"txtOrganiserName"]];
		}
		if ([dict objectForKey:@"txtPlaydateLocation"]) {
			lbl_location.text = [dict objectForKey:@"txtPlaydateLocation"];
		}
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	if ([[self.dict_data objectForKey:@"Activities"] count]) {
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		
		PastPlaydateDetailsViewController *details = [[PastPlaydateDetailsViewController alloc]initWithNibName:@"PastPlaydateDetailsViewController" bundle:nil];
		details.prevContImage = currentImage;
		details.playdate_id = [[[self.dict_data objectForKey:@"Activities"] objectAtIndex:indexPath.row] objectForKey:@"txtPid"];
		[self.navigationController pushViewController:details animated:NO];
		[details release];
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
	}
	

}


- (void) upcomingPlaydatesResponse : (NSData *)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		if ([[self.dict_data objectForKey:@"Activities"] count] && [[response objectForKey:@"response"] objectForKey:@"Activities"]) {
			[[self.dict_data objectForKey:@"Activities"] addObjectsFromArray:[[response objectForKey:@"response"] objectForKey:@"Activities"]];
		}else if (![[self.dict_data allKeys] count] && [[[response objectForKey:@"response"] allKeys] count]) {
			self.dict_data = [response objectForKey:@"response"];
		} else {
			
//			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
//																message:@"No More past Playdates."// MSG_ERROR_VALID_REGISTER4
//															   delegate:nil
//													  cancelButtonTitle:@"Ok" 
//													  otherButtonTitles:nil];
//			[alertView show];
//			[alertView release];
		}
		[self.theTableView reloadData];
	}
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
