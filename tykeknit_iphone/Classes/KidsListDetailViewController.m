//
//  KidsListDetailViewController.m
//  TykeKnit
//
//  Created by Ver on 23/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
#define PHOTO_INDENT 74.0
#import "ParentDetailViewController.h"
#import "KidsListDetailViewController.h"
#import "PlaydateScheduleViewController.h";
#import "CustomTableViewCell.h"
#import "Global.h"
#import "JSON.h"
#import "TykeKnitApi.h"
#import "UIImage+Helpers.h"
#import "TableCellImageView.h"

@implementation KidsListDetailViewController
@synthesize theTableView,dict_Data,dict_scheduleData, child_id, isWannaHang;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
    [super viewDidLoad];
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Tyke Details"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	
	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate =self;
	
	[DELEGATE addLoadingView:self.view];
	[api_tyke getChildProfileDetails:child_id];
}

- (void) backPressed :(id) sender{
	
	[self popViewController];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	for (NSDictionary *dict in [self.dict_scheduleData objectForKey:@"additionalInvitees"]) {
		if ([self.child_id isEqualToString:[dict objectForKey:@"childId"]]) {
			return 2;
		}
	}
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section==0) 	
		return 53;
	else 
		return 44;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	if (section==1 && ![[self.dict_Data objectForKey:@"SecondaryPR"]isEqualToString:@"[]"])
		return 2;
	else
		return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *view_ForHeader = [[UIView alloc]initWithFrame:CGRectMake(0,0,250,25)];
	UILabel *headerForSection = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, 17)];
	[headerForSection setBackgroundColor:[UIColor clearColor]];
	headerForSection.font = [UIFont boldSystemFontOfSize:15];
	if (section==1) {
		headerForSection.text = @"Parents";
	}else if (section==2) {
		headerForSection.text = @"PlayDates";
	}
	headerForSection.textColor = [UIColor darkGrayColor];
	[view_ForHeader addSubview:headerForSection];
	[headerForSection release];
	
	return [view_ForHeader autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section==0) {
		return 20.0;
	}
	return 25.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	if (indexPath.section==0) {
		
		NSString *CellIdentifier = @"InfoCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			TableCellImageView *img_kidpic = [[TableCellImageView alloc]initWithFrame:CGRectMake(10, 5, 42, 42)];
			img_kidpic.tag = 1;
			img_kidpic.defaultImage = [UIImage imageWithContentsOfFile:getImagePathOfName(@"tyke_knit_default")];
			[cell.contentView addSubview:img_kidpic];
			[img_kidpic release];
			
			UILabel *lbl_FirstName = [[UILabel alloc]initWithFrame:CGRectMake(60, 7, 150, 20)];
			lbl_FirstName.tag = 3;				
			lbl_FirstName.text = @"first name";
			[lbl_FirstName setTextColor:[UIColor darkGrayColor]];
			lbl_FirstName.backgroundColor = [UIColor clearColor];
			lbl_FirstName.font = [UIFont fontWithName:@"helvetica Neue" size:16];
			lbl_FirstName.font = [UIFont boldSystemFontOfSize:16];
			[cell.contentView addSubview:lbl_FirstName];
			[lbl_FirstName release];
			
			UIImageView *img_status = [[UIImageView alloc] initWithFrame:CGRectMake(60, 25, 18, 18)];
			img_status.tag = 4;
			img_status.backgroundColor = [UIColor clearColor];
			[cell.contentView addSubview:img_status];
			[img_status release];
			
			UILabel *lbl_status = [[UILabel alloc] initWithFrame:CGRectMake( 80, 25, 150, 18)];
			lbl_status.tag = 5;
			lbl_status.textColor = [UIColor grayColor];
			lbl_status.backgroundColor = [UIColor clearColor];
			[lbl_status setFont:[UIFont boldSystemFontOfSize:12]];
			[cell.contentView addSubview:lbl_status];
			[lbl_status release];
		}
		
		TableCellImageView *img_kidPic = (TableCellImageView *)[cell viewWithTag:1];
		UILabel *lblFirstName = (UILabel *)[cell viewWithTag:3];
		UIImageView *img_status = (UIImageView *)[cell viewWithTag:4];
		UILabel *lbl_status = (UILabel *)[cell viewWithTag:5];

		[img_kidPic setImageUrl:[self.dict_Data objectForKey:@"photoURL"]];
		if ([self.dict_Data objectForKey:@"txtFirstName"]) {
			lblFirstName.text = [self.dict_Data objectForKey:@"txtFirstName"];
		}
		
		if (self.isWannaHang) {
			lbl_status.text = @"Wanna Hang";
			[img_status setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_wannaHang")]];
		}else {
			lbl_status.text = @"In-Knit";
			[img_status setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_InKnit")]];
		}
		return cell;
	}
	else if(indexPath.section==1){
		
		NSString *CellIdentifier = @"childInfo";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(15, 2, 240, 40)];
			lblFirstName.tag = 16;
			lblFirstName.numberOfLines = 0;
			[lblFirstName setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			lblFirstName.font = [UIFont boldSystemFontOfSize:14];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
		}
		
		UILabel *lbl_firstName = (UILabel *)[cell viewWithTag:16];
		
		if ([[self.dict_Data objectForKey:@"primaryParent"] objectForKey:@"firstName"] && indexPath.row==0) {
			lbl_firstName.text = [NSString stringWithFormat:@"%@ %@",[[self.dict_Data objectForKey:@"primaryParent"] objectForKey:@"firstName"],[[self.dict_Data objectForKey:@"primaryParent"] objectForKey:@"lastName"]];
		}
		
		NSArray *spouseArray = [[self.dict_Data objectForKey:@"SecondaryPR"] JSONValue];
		if ([spouseArray count] && indexPath.row==1) {
			lbl_firstName.text = [NSString stringWithFormat:@"%@ %@",[[spouseArray objectAtIndex:0] objectForKey:@"firstName"],
								  [[spouseArray objectAtIndex:0] objectForKey:@"lastName"]
								  ];
		}
		
		return cell;
	}
	else if (indexPath.section==2) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"section 3"];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"section 3"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			
			UILabel *lbl_playdate = [[UILabel alloc]initWithFrame:CGRectMake(20, 12, 200, 20)];
			lbl_playdate.tag = 21;
			lbl_playdate.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			[lbl_playdate setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			[cell.contentView addSubview:lbl_playdate];
			[lbl_playdate release];
		}
		
		UILabel *lbl_playdate = (UILabel *)[cell viewWithTag:21];
		lbl_playdate.text = @"13 upcoming playdates";
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"section"];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"section"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		}
	}	
	return cell;
}		

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section==1) {
		
		int index =	[[self.navigationController viewControllers] indexOfObject:self];
		if ([[[self.navigationController viewControllers] objectAtIndex:index-1] isKindOfClass:[ParentDetailViewController class]]) {
			ParentDetailViewController *parent = (ParentDetailViewController *)[[self.navigationController viewControllers] objectAtIndex:index-1];
			NSArray *spouseArray = [[self.dict_Data objectForKey:@"SecondaryPR"] JSONValue];		
			if (indexPath.row==0) {
				[parent reloadForSpouse:[[self.dict_Data objectForKey:@"primaryParent"] objectForKey:@"id"]];
				[parent popViewController];
			}else if (indexPath.row == 1) {
				[parent reloadForSpouse:[[spouseArray objectAtIndex:0] objectForKey:@"id"]];
				[parent popViewController];
			}
			//	[self popViewController];
		}else {
			[self popViewController];
		}
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString *) dateFormatter:(NSIndexPath *) indexPath{
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-DD"];
    NSDate *dt =[formatter dateFromString:[self.dict_Data objectForKey:@"txtDOB"]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit ;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:dt toDate:[NSDate date] options:0];
	NSString *dateFormat = nil;
	
    if([components year]){
		dateFormat = [NSString stringWithFormat:@"%d", [components year]];
    }else if([components month]){
        dateFormat= [NSString stringWithFormat:@"%d Months ago", [components month]];
    }else if([components day]){
		dateFormat = [NSString stringWithFormat:@"%d Days ago", [components day]];
    }else if([components hour]){
		dateFormat = [NSString stringWithFormat:@"%d Hours ago", [components hour]];
	}else if([components  minute]){
		dateFormat = [NSString stringWithFormat:@"%d Minutes ago", [components minute]];
	}else if([components  second]){
		dateFormat = [NSString stringWithFormat:@"%d Hours ago", [components second]];
	}
	
    [formatter release];
    [gregorian release];
	return dateFormat;
}

-(void) btnRequestClicked:(id)sender {
	
	[self.dict_Data setObject:self.child_id forKey:@"childId"];
	
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	
	NSMutableArray *arr_additionalInvitees = nil;
	if (![self.dict_scheduleData objectForKey:@"additionalInvitees"]) {
		arr_additionalInvitees = [[NSMutableArray alloc]init];
		[arr_additionalInvitees addObject:self.dict_Data];
		[self.dict_scheduleData setObject:arr_additionalInvitees forKey:@"additionalInvitees"];
		[arr_additionalInvitees release];
	}else {
		arr_additionalInvitees = [self.dict_scheduleData objectForKey:@"additionalInvitees"];
		[arr_additionalInvitees addObject:self.dict_Data];
	}
	
	
	
	PlaydateScheduleViewController *playdateScheduleViewController = [[PlaydateScheduleViewController alloc]initWithNibName:@"PlaydateScheduleViewController" bundle:nil];
	playdateScheduleViewController.prevContImage = currentImage;
	playdateScheduleViewController.dict_kidData = self.dict_Data;
	playdateScheduleViewController.dict_scheduleData = self.dict_scheduleData;
	[self.navigationController pushViewController:playdateScheduleViewController animated:NO];
	[playdateScheduleViewController release];
}

- (void) getChildProfDetailResp : (NSData*) data {
	
	NSMutableDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.view];
	[self.dict_Data removeAllObjects];
	self.dict_Data = [response objectForKey:@"response"];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		[self.theTableView reloadData];
	}else {
		UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
														   message:[[response objectForKey:@"reason"] objectForKey:@"reasonStr"]// MSG_ERROR_VALID_REGISTER4
														  delegate:nil 
												 cancelButtonTitle:@"Ok" 
												 otherButtonTitles:nil];
		[objAlert show];
		[objAlert release];
	}
	
	
	
}

- (void) noNetworkConnection {
	
	loadingRequest = NO;
	[DELEGATE removeLoadingView:self.vi_main];
}

- (void) failWithError : (NSError*) error {
	
	loadingRequest = NO;
	[DELEGATE removeLoadingView:self.vi_main];
}

- (void) requestCanceled {
	
	loadingRequest = NO;
	[DELEGATE removeLoadingView:self.vi_main];
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
	[self.dict_Data release];
    [super dealloc];
}


@end
