//
//  ParentDetailViewController.m
//  TykeKnit
//
//  Created by Ver on 17/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#define PHOTO_INDENT 74.0

#import "ParentDetailViewController.h"
#import "MyFriendsViewController.h"
#import "CommonFriendsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PlaydateScheduleViewController.h"
#import "Global.h"
#import "JSON.h"
#import "CustomTableViewCell.h"
#import "KidsListDetailViewController.h"
#import "TableCellImageView.h"

@implementation ParentDetailViewController
@synthesize dict_data,theTableView,dict_scheduleData,api_tyke,parent_ID,degree_code,spouseDetailsToShow;


- (void) reloadForSpouse : (NSString *)spouse_id {

	if (![spouse_id isEqualToString:self.parent_ID]) {
		[self.dict_data removeAllObjects];
		[DELEGATE addLoadingView:self.vi_main];
		self.parent_ID = spouse_id;
		[api_tyke getUserProfile:self.parent_ID];
	}
}


- (void) backPressed : (id) sender {
	[self popViewController];
}

- (void) viewWillAppear:(BOOL)animated {
	
	if ([[[DELEGATE window] subviews] containsObject:[DELEGATE nav_wannaHangBar].view]) {
		[[DELEGATE nav_wannaHangBar].view removeFromSuperview];
	}
	
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_playDateSearch aboveSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_playDate_send belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_wannaHang belowSubview:[DELEGATE vi_sideView].img_back];
	//	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_settings3 belowSubview:[DELEGATE vi_sideView].img_back];
	
	[super viewWillAppear:animated];
}

- (void) viewDidLoad {
	
	UIButton *btn_cancel = [DELEGATE getBackBarButton];
	[btn_cancel addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_cancel] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Parent Profile"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	[super viewDidLoad];
	
	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate = self;
	if (self.parent_ID) {
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke getUserProfile:self.parent_ID];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadForSpouseData) name:@"ReloadForSpouseData" object:nil];
}

- (void) MarkUserPosResponse : (NSData*)data {
//	NSDictionary *response = [[data stringValue] JSONValue];
}

#pragma mark -
#pragma mark UITableViewDelagate Methods


- (NSString*) getSectionLabelForSection:(int)section {
	NSString *strLabel = nil;
	if (section==0) {
		strLabel = @"InfoCell";
	}
	if (section==1 && [[[self.dict_data objectForKey:@"spouseDetails"] allKeys] count]) {
		strLabel = @"SpouseCell";
	}
	else if (section == 1) {
		strLabel = @"TykeCell";
	}
	if (section==2 && [[[self.dict_data objectForKey:@"spouseDetails"] allKeys] count]) {
		strLabel = @"TykeCell";
	}else if (section==2) {
		strLabel = @"CommonCell";
	}
	
	if (section==3 && [[[self.dict_data objectForKey:@"spouseDetails"] allKeys] count]) {
		strLabel = @"CommonCell";
	}else if (section==3) {
		strLabel = @"ButtonCell";
	}
	
	if (section==4) {
		strLabel = @"ButtonCell";
	}
	return strLabel;
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell = nil;

	self.theTableView.backgroundColor = [UIColor colorWithRed:0.875 green:0.906 blue:0.918 alpha:1.0];
	NSString *strLabel = [self getSectionLabelForSection:[indexPath section]];
	if ([strLabel isEqualToString:@"InfoCell"]) {
		
		NSString *CellIdentifier = @"InfoCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			
			TableCellImageView *img_user = [[TableCellImageView alloc]initWithFrame:CGRectMake(10, 5, 42, 42)];
			img_user.defaultImage = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
			img_user.tag = 1;
			[cell.contentView addSubview:img_user];
			[img_user release];
			
			UILabel *lbl_FirstName = [[UILabel alloc]initWithFrame:CGRectMake(60, 7, 200, 20)];
			lbl_FirstName.tag = 3;				
			lbl_FirstName.text = @"first name";
			lbl_FirstName.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			lbl_FirstName.font = [UIFont fontWithName:@"helvetica Neue" size:16];
			[lbl_FirstName setTextColor:[UIColor darkGrayColor]];
			lbl_FirstName.backgroundColor = [UIColor clearColor];
			lbl_FirstName.font = [UIFont boldSystemFontOfSize:16];
			[cell.contentView addSubview:lbl_FirstName];
			[lbl_FirstName release];
			
			UIImageView *img_wannahang = [[UIImageView alloc]initWithFrame:CGRectMake(57,  27, 18, 18)];
			img_wannahang.tag = 4;
			[img_wannahang setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"wanna-hang-orange.png")]];
			[cell.contentView addSubview:img_wannahang];
			[img_wannahang release];
			
			UILabel *lbl_Status = [[UILabel alloc]initWithFrame:CGRectMake(84, 28, 150, 18)];
			lbl_Status.tag = 5;
			lbl_Status.text = @"Out Of Knit";
			lbl_Status.textColor = [UIColor lightGrayColor];
			lbl_Status.backgroundColor = [UIColor clearColor];
			lbl_Status.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			lbl_Status.font = [UIFont systemFontOfSize:14];
			[cell.contentView addSubview:lbl_Status];
			[lbl_Status release];
			
		}
		TableCellImageView *img_user = (TableCellImageView *)[cell viewWithTag:1];
		UILabel *lblFirstName = (UILabel *)[cell viewWithTag:3];
		UIImageView *img_wannahang = (UIImageView *)[cell viewWithTag:4];
		UILabel *lblStatus = (UILabel *)[cell viewWithTag:5];
		
		NSDictionary *dict = [self.dict_data objectForKey:@"userDetails"];
		if ([dict objectForKey:@"firstName"] && [dict objectForKey:@"lastName"]) {
			lblFirstName.text = [NSString stringWithFormat:@"%@ %@",[dict objectForKey:@"firstName"],[dict objectForKey:@"lastName"]];
		}
		if ([self.degree_code isEqualToString:@"3"]) {
			lblStatus.text =@"Out Of Knit";
			img_wannahang.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_OutOfKnit")];
		}else if ([self.degree_code isEqualToString:@"2"]) {
			lblStatus.text =@"Out Of Knit";
			img_wannahang.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_OutOfKnit")];
		}else if ([self.degree_code isEqualToString:@"1"] || [self.degree_code isEqualToString:@"0"]) {
			lblStatus.text = @"In Knit";
			img_wannahang.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_InKnit")];
			for (NSDictionary *dict in [self.dict_data objectForKey:@"Kids"]) {
				if ([[dict objectForKey:@"status"] isEqualToString:@"t"]) {
					img_wannahang.image =[UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_wannaHang")];
					break;
				}
			}
		}
		img_user.defaultImage = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
		[img_user setImageUrl:[dict objectForKey:@"picURL"]];
		
		return cell;
		
	}else if ([strLabel isEqualToString:@"SpouseCell"]) {
		NSString *Identifier = @"SpouseCell";
		cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
		cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			if (spouseDetailsToShow) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}

			UILabel *lbl_FirstName = [[UILabel alloc] initWithFrame:CGRectMake(20, 13, 240, 20)];
			lbl_FirstName.tag = 33;				
			lbl_FirstName.text = @"first name";
			[lbl_FirstName setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			lbl_FirstName.font = [UIFont fontWithName:@"helvetica Neue" size:16];
			lbl_FirstName.backgroundColor = [UIColor clearColor];
			lbl_FirstName.font = [UIFont systemFontOfSize:16];
			[cell.contentView addSubview:lbl_FirstName];
			[lbl_FirstName release];
		}
		
		UILabel *lbl_spouseName = (UILabel *)[cell.contentView viewWithTag:33];
		
		if ([[self.dict_data objectForKey:@"spouseDetails"] objectForKey:@"firstName"] && [[self.dict_data objectForKey:@"spouseDetails"] objectForKey:@"lastName"]) {
			lbl_spouseName.text = [NSString stringWithFormat:@"%@ %@",[[self.dict_data objectForKey:@"spouseDetails"] objectForKey:@"firstName"],[[self.dict_data objectForKey:@"spouseDetails"] objectForKey:@"lastName"]];
		}
		
		CGSize aSize = [lbl_spouseName.text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(240, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
		lbl_spouseName.frame = CGRectMake(20, 10, aSize.width, aSize.height);

		return cell;
			
	}
	else if([strLabel isEqualToString:@"TykeCell"]) {
		NSString *Identifier = @"TykeCell";
		cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			if ([self.degree_code isEqualToString:@"1"] || [self.degree_code isEqualToString:@"0"]) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.selectionStyle = UITableViewCellSelectionStyleGray;
			}

			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 100, 20)];
			lblFirstName.tag = 16; 
			[lblFirstName setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font = [UIFont fontWithName:@"helvetica Neue" size:15];
			lblFirstName.font = [UIFont systemFontOfSize:15];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
		
			UILabel *lbl_childAge = [[UILabel alloc]initWithFrame:CGRectMake(140, 26, 100, 20)];
			[lbl_childAge setTag:18];
			[lbl_childAge setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			[lbl_childAge setBackgroundColor:[UIColor clearColor]];
			lbl_childAge.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			[lbl_childAge setFont:[UIFont systemFontOfSize:14]];
			[cell.contentView addSubview:lbl_childAge];
			[lbl_childAge release];
			
			UIImageView *img_lock = [[UIImageView alloc]initWithFrame:CGRectMake(230, 12, 13, 17)];
			img_lock.tag = 19;
			[img_lock setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"private_Lock")]];
			[cell.contentView addSubview:img_lock];
			[img_lock release];
	}
		
		UILabel *lbl_Name = (UILabel*)[cell viewWithTag:16];
		UILabel *lbl_childAge = (UILabel *)[cell viewWithTag:18];
		UIImageView *img_lock = (UIImageView *)[cell.contentView viewWithTag:19];
		
		NSArray *arr_kids = [self.dict_data objectForKey:@"Kids"];
		
		if([[[self.dict_data objectForKey:@"userDetails"] objectForKey:@"privacyEnforcedFlag"] intValue]) {
			cell.accessoryType = UITableViewCellAccessoryNone;
			lbl_Name.frame = CGRectMake(13, 13, 100, 17);
			lbl_Name.shadowColor = [UIColor whiteColor];
			lbl_Name.shadowOffset = CGSizeMake(0, 1);
			lbl_Name.text = @"Private";
			lbl_Name.textColor = [UIColor lightGrayColor];
			lbl_childAge.text = @"";
			img_lock.hidden = NO;
			return cell;
		}
		img_lock.hidden = YES;
		if ([[arr_kids objectAtIndex:indexPath.row] objectForKey:@"firstName"] && [[arr_kids objectAtIndex:indexPath.row] objectForKey:@"lastName"]) {
			lbl_Name.text = [NSString stringWithFormat:@" %@ %@",[[arr_kids objectAtIndex:indexPath.row] objectForKey:@"firstName"],[[arr_kids objectAtIndex:indexPath.row] objectForKey:@"lastName"]];
		}
		if ([[arr_kids objectAtIndex:indexPath.row] objectForKey:@"DOB"]) {
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"yyyy-MM-dd"];
			NSDate *DOB = [formatter dateFromString:[[arr_kids objectAtIndex:indexPath.row] objectForKey:@"DOB"]];
			[formatter release];
			lbl_childAge.text =  [NSString stringWithFormat:@"(%@)",getChildAgeFromDate(DOB)];
		}

		if ([[[arr_kids objectAtIndex:indexPath.row] objectForKey:@"gender"] isEqualToString:@"M"]) {
			lbl_childAge.textColor =BoyBlueColor;
		}else {
			lbl_childAge.textColor =GirlPinkColor;
		}
		
		if ([[[arr_kids objectAtIndex:indexPath.row] objectForKey:@"status"] isEqualToString:@"t"]) {
			lbl_Name.textColor = WannaHangColor;
		}else {
			[lbl_Name setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
		}

		CGSize aSize = [lbl_Name.text sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(180, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
		lbl_Name.frame = CGRectMake(13, 11, aSize.width, 20);
		aSize = [lbl_childAge.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(150, FLT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
		lbl_childAge.frame = CGRectMake(lbl_Name.frame.origin.x+lbl_Name.frame.size.width+3, 11, aSize.width, 20);

		return cell;
		
	}
	else if([strLabel isEqualToString:@"ButtonCell"]) {
		NSString *identifier = @"ButtonCell";
		cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			UIButton *btn_cell = [UIButton buttonWithType:UIButtonTypeCustom];
			btn_cell.tag = 41;
			btn_cell.frame = CGRectMake(-5, 0, 273, 44);
			btn_cell.backgroundColor = [UIColor clearColor];
			[btn_cell addTarget:self action:@selector(sendClicked:) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:btn_cell];
			cell.backgroundColor = [UIColor clearColor];
		}
		
		UIButton *btn_cell = (UIButton *)[cell.contentView viewWithTag:41];
		
		if ([self.degree_code isEqualToString:@"3"]) {
			[btn_cell setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_sendKnitroduction")] forState:UIControlStateNormal];
		}else if ([self.degree_code isEqualToString:@"1"] || [self.degree_code isEqualToString:@"0"]) {
			[btn_cell setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_planPlaydate2")] forState:UIControlStateNormal];
		}else if ([self.degree_code isEqualToString:@"2"]) {
			[btn_cell setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_sendKnitroduction")] forState:UIControlStateNormal];
			//[btn_cell setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_planPlaydate2.png")] forState:UIControlStateNormal];
		}
		return cell;
	}
	else if([strLabel isEqualToString:@"CommonCell"]) {
		NSString *identifier = @"CommonCell";
		cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
			if ([self.dict_data objectForKey:@"CommonFriends"]) {
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
						
			UILabel *lbl_common = [[UILabel alloc]initWithFrame:CGRectMake(13, 12, 250, 20)];
			[lbl_common setBackgroundColor:[UIColor clearColor]];
			[lbl_common setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			lbl_common.font = [UIFont fontWithName:@"helvetica Neue" size:16];
			[lbl_common setFont:[UIFont systemFontOfSize:16]];
			[lbl_common setTag:31];
			[cell.contentView addSubview:lbl_common];
			[lbl_common release];
			
		}
		
		UILabel *lbl_common = (UILabel *)[cell viewWithTag:31];
		if ([[self.dict_data objectForKey:@"commonFriends"] count] > 1) {
			lbl_common.text = [NSString stringWithFormat:@"%d Common Friends",[[self.dict_data objectForKey:@"commonFriends"] count]-1];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}else {
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			lbl_common.text = @"No common friends";
		}
		return cell;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section==1 || section==2) {
		return 20.0;
	}
	else return 5.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (section==1 || section ==2) {
		
		NSString *strLabel = [self getSectionLabelForSection:section];
		
		UIView *vi_header = [[UIView alloc]initWithFrame:CGRectZero];
		UILabel *lbl_header = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, 80, 20)];
		[lbl_header setFont:[UIFont boldSystemFontOfSize:16]];
		[lbl_header setTextColor:[UIColor darkGrayColor]];
		
		if ([strLabel isEqualToString:@"TykeCell"]) {
			[vi_header setFrame:CGRectMake(0, 0, 80, 20)];
			[lbl_header setText:@"Tykes"];	
		}else if ([strLabel isEqualToString:@"SpouseCell"]) {
			[vi_header setFrame:CGRectMake(0, 0, 80, 20)];
			[lbl_header setText:@"Spouse"];	
		}else if ([strLabel isEqualToString:@"CommonCell"]) {
			[vi_header setFrame:CGRectMake(0, 0, 80, 20)];
			[lbl_header setText:@"Common"];	
		}
		[lbl_header setBackgroundColor:[UIColor clearColor]];
		lbl_header.layer.shadowOffset = CGSizeMake(0, 5.0);
		lbl_header.layer.shadowColor = [UIColor whiteColor].CGColor;
		[vi_header addSubview:lbl_header];
		[lbl_header release];
		
		return [vi_header autorelease];	
	}else return nil;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	if ([[[self.dict_data objectForKey:@"spouseDetails"] allKeys] count] && spouseDetailsToShow) {
		return 5;
	}
	return 4;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	NSString *strLabel = [self getSectionLabelForSection:section];
	if ([strLabel isEqualToString:@"TykeCell"] ) {
		if ([[self.dict_data objectForKey:@"Kids"] count] == 0) {
			if ([[[self.dict_data objectForKey:@"userDetails"] objectForKey:@"privacyEnforcedFlag"] intValue]) {
				return 1;
			}
		}
		return [[self.dict_data objectForKey:@"Kids"] count];
	}else
		return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

	if (indexPath.section == 0) {
		return 53;
	} else return 44;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

	NSString *strLabel = [self getSectionLabelForSection:indexPath.section];
	if ([strLabel isEqualToString:@"TykeCell"]) {
		if ([self.degree_code isEqualToString:@"1"] || [self.degree_code isEqualToString:@"0"]) {
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			
			NSDictionary *kidDict = [[self.dict_data objectForKey:@"Kids"] objectAtIndex:indexPath.row];
			KidsListDetailViewController *kidsListDetailViewController = [[KidsListDetailViewController alloc]initWithNibName:@"KidsListDetailViewController" bundle:nil];
			if ([[kidDict objectForKey:@"txtWannaHang"] isEqualToString:@"f"]) {
				kidsListDetailViewController.isWannaHang = NO;
			}else {
				kidsListDetailViewController.isWannaHang = YES;
			}
			kidsListDetailViewController.child_id = [kidDict objectForKey:@"id"];
			kidsListDetailViewController.dict_scheduleData = self.dict_scheduleData;
			kidsListDetailViewController.prevContImage = currentImage;
			[self.navigationController pushViewController:kidsListDetailViewController animated:NO];
			[kidsListDetailViewController release];
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
		}
	}else if ([strLabel isEqualToString:@"SpouseCell"]) {

		if (spouseDetailsToShow) {
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			
			NSDictionary *dict = [self.dict_data objectForKey:@"spouseDetails"];
			ParentDetailViewController *parentDetailViewController = [[ParentDetailViewController alloc]initWithNibName:@"ParentDetailViewController" bundle:nil];
			parentDetailViewController.prevContImage = currentImage;
			parentDetailViewController.parent_ID = [dict objectForKey:@"id"];
			parentDetailViewController.degree_code = @"0";
			parentDetailViewController.spouseDetailsToShow = NO;
			parentDetailViewController.dict_scheduleData = self.dict_scheduleData;
			[self.navigationController pushViewController:parentDetailViewController animated:NO];
			[parentDetailViewController release];
		}
	}
	if ([strLabel isEqualToString:@"ButtonCell"]) {
		
	}else if ([strLabel isEqualToString:@"CommonCell"]) {

		if ([[self.dict_data objectForKey:@"commonFriends"] count] > 1) {
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			
			CommonFriendsViewController *common = [[CommonFriendsViewController alloc] initWithNibName:@"CommonFriendsViewController" bundle:nil];
			common.prevContImage = currentImage;
			common.arr_friendsData = [self.dict_data objectForKey:@"commonFriends"];
			[self.navigationController pushViewController:common animated:NO];
			[common release];
		}
	}
	[self.theTableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void) sendClicked : (id) sender {
	if ([self.degree_code isEqualToString:@"3"] || [self.degree_code isEqualToString:@"2"]) {
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke joinKnitRequest:self.parent_ID];
	}else if ([self.degree_code isEqualToString:@"1"] || [self.degree_code isEqualToString:@"0"]) {
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		

		NSMutableArray *buddies = [[NSMutableArray alloc]init];
		NSMutableDictionary *selectedBuddy = [[NSMutableDictionary alloc]init];
		
		NSMutableArray *arr_kids = [self.dict_data objectForKey:@"Kids"];
		NSMutableArray *arr_tykes = [[NSMutableArray alloc]init];
		
		for (NSMutableDictionary *dict in arr_kids) {
			NSMutableDictionary *tyke = [[NSMutableDictionary alloc]init];
			[tyke setObject:[dict objectForKey:@"firstName"] forKey:@"txtFirstName"];
			[tyke setObject:[dict objectForKey:@"lastName"] forKey:@"txtLastName"];
			[tyke setObject:[dict objectForKey:@"DOB"] forKey:@"txtDOB"];
			[tyke setObject:[dict objectForKey:@"status"] forKey:@"WannaHang"];
			[tyke setObject:[dict objectForKey:@"id"] forKey:@"cid"];
			[tyke setObject:@"1" forKey:@"selected"];
			[arr_tykes addObject:tyke];
			[tyke release];
		}
		
		[selectedBuddy setObject:self.parent_ID forKey:@"ParentUserTblPk"];
		[selectedBuddy setObject:@"1" forKey:@"selected"];
		[selectedBuddy setObject:[[self.dict_data objectForKey:@"userDetails"] objectForKey:@"firstName"] forKey:@"ParentFName"];
		[selectedBuddy setObject:[[self.dict_data objectForKey:@"userDetails"] objectForKey:@"lastName"] forKey:@"ParentLName"];
		[selectedBuddy setObject:arr_tykes forKey:@"Tykes"];
		[arr_tykes release];
		[buddies addObject:selectedBuddy];
		[selectedBuddy release];

		[self.dict_scheduleData setObject:buddies forKey:@"buddies"];
		[buddies release];
		
		PlaydateScheduleViewController *playdateScheduleViewController = [[PlaydateScheduleViewController alloc]initWithNibName:@"PlaydateScheduleViewController" bundle:nil];
		playdateScheduleViewController.prevContImage = currentImage;
		playdateScheduleViewController.selectedBuddy = self.parent_ID;
		playdateScheduleViewController.dict_scheduleData = self.dict_scheduleData;
		[self.navigationController pushViewController:playdateScheduleViewController animated:NO];
		[playdateScheduleViewController release];
	}
}

- (void) getUserProfileResponse : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		self.dict_data = [response objectForKey:@"response"];
		[self.theTableView reloadData];
	}
}	
- (void) joinKnitRequestResponse : (NSData*)data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Congratulations" 
													   message:@"Invitation sent successfully"
													  delegate:self cancelButtonTitle:@"Ok" 
											 otherButtonTitles:nil];
		[alert setTag:300];
		[alert show];
		[alert release];
	}else {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" 
  													   message:[[response objectForKey:@"reason"] objectForKey:@"reasonStr"]
													  delegate:self cancelButtonTitle:@"Ok" 
											 otherButtonTitles:nil];
		[alert setTag:300];
		[alert show];
		[alert release];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag = 300) {
		[self popViewController];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReloadForSpouseData" object:nil];
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}

@end
