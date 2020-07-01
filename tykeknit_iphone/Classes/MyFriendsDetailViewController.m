//
//  MyFriendsDetailViewController.m
//  TykeKnit
//
//  Created by Ver on 14/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyFriendsDetailViewController.h"
#import "CommonFriendsViewController.h"
#import "JSON.h"
#import "TableCellImageView.h"
#import "KidsListDetailViewController.h"
#import "PlaydateScheduleViewController.h"

@implementation MyFriendsDetailViewController
@synthesize dict_data,theTableView,api_tyke,friendId,degree;

- (void) backPressed : (id) sender {
	[self popViewController];
}
- (void) viewDidLoad {
	
	UIButton *btn_cancel = [DELEGATE getBackBarButton];// getDefaultBarButtonWithTitle:@"Back"];
	[btn_cancel addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_cancel] autorelease];
	
	//	UIButton *btn_done = [DELEGATE getDefaultBarButtonWithTitle:@"Done"];
	//	[btn_done addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	//	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_done] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Friends"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	[super viewDidLoad];

	api_tyke = [[TykeKnitApi alloc]init];
	api_tyke.delegate = self;
	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke getUserProfile:friendId];
}

- (void) sendClicked : (id) sender {
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	
	NSMutableDictionary *dict_scheduleData = [[NSMutableDictionary alloc]init];
	NSMutableArray *buddies = [[NSMutableArray alloc]init];
	NSMutableDictionary *selectedBuddy = [[NSMutableDictionary alloc]init];
	
	NSMutableArray *arr_kids = [self.dict_data objectForKey:@"Kids"];
	NSMutableArray *arr_tykes = [[NSMutableArray alloc]init];
	
	for (NSMutableDictionary *dict in arr_kids) {
		NSMutableDictionary *tyke = [[NSMutableDictionary alloc]init];
		[tyke setObject:[dict objectForKey:@"firstName"] forKey:@"txtFirstName"];
		[tyke setObject:[dict objectForKey:@"lastName"] forKey:@"txtLastName"];
		[tyke setObject:[dict objectForKey:@"status"] forKey:@"WannaHang"];
		[tyke setObject:[dict objectForKey:@"id"] forKey:@"cid"];
		[tyke setObject:@"1" forKey:@"selected"];
		[arr_tykes addObject:tyke];
		[tyke release];
	}
	
	[selectedBuddy setObject:self.friendId forKey:@"ParentUserTblPk"];
	[selectedBuddy setObject:@"1" forKey:@"selected"];
	[selectedBuddy setObject:[[self.dict_data objectForKey:@"userDetails"] objectForKey:@"firstName"] forKey:@"ParentFName"];
	[selectedBuddy setObject:[[self.dict_data objectForKey:@"userDetails"] objectForKey:@"lastName"] forKey:@"ParentLName"];
	[selectedBuddy setObject:arr_tykes forKey:@"Tykes"];
	[arr_tykes release];
	[buddies addObject:selectedBuddy];
	[selectedBuddy release];
	
	[dict_scheduleData setObject:buddies forKey:@"buddies"];
	[buddies release];
	
	PlaydateScheduleViewController *playdateScheduleViewController = [[PlaydateScheduleViewController alloc]initWithNibName:@"PlaydateScheduleViewController" bundle:nil];
	playdateScheduleViewController.prevContImage = currentImage;
	playdateScheduleViewController.selectedBuddy = self.friendId;
	playdateScheduleViewController.dict_scheduleData = dict_scheduleData;
	[self.navigationController pushViewController:playdateScheduleViewController animated:NO];
	[playdateScheduleViewController release];

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
	
	NSString *strLabel = [self getSectionLabelForSection:[indexPath section]];
	if ([strLabel isEqualToString:@"InfoCell"]) {
		
		NSString *CellIdentifier = @"InfoCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
		
			
			TableCellImageView *img_KidPic = [[TableCellImageView alloc]initWithFrame:CGRectMake(10, 5, 42, 42)];
			img_KidPic.defaultImage = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
			img_KidPic.tag = 1;
			[cell.contentView addSubview:img_KidPic];
			[img_KidPic release];
			
			UILabel *lbl_FirstName = [[UILabel alloc]initWithFrame:CGRectMake(60, 7, 150, 20)];
			lbl_FirstName.tag = 3;				
			lbl_FirstName.text = @"first name";
			lbl_FirstName.textColor = [UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0];
			lbl_FirstName.font = [UIFont fontWithName:@"helvetica Neue" size:16];
			[lbl_FirstName setTextColor:[UIColor darkGrayColor]];
			lbl_FirstName.backgroundColor = [UIColor clearColor];
			lbl_FirstName.font = [UIFont boldSystemFontOfSize:16];
			[cell.contentView addSubview:lbl_FirstName];
			[lbl_FirstName release];
			
			UIImageView *img_wannahang = [[UIImageView alloc]initWithFrame:CGRectMake(57, 27, 20, 20)];
			//			[img_wannahang setBackgroundColor:[UIColor grayColor]];
			img_wannahang.tag = 4;
//			[img_wannahang setImage:[UIImage imageWithC//ontentsOfFile:VXTPathForBundleResource(@"wanna-hang-orange.png")]];
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
		
		if ([[self.dict_data objectForKey:@"userDetails"]objectForKey:@"firstName"] && [[self.dict_data objectForKey:@"userDetails"] objectForKey:@"lastName"]) {
			lblFirstName.text = [NSString stringWithFormat:@"%@ %@",[[self.dict_data objectForKey:@"userDetails"]objectForKey:@"firstName"],[[self.dict_data objectForKey:@"userDetails"] objectForKey:@"lastName"]];
		}
		[img_user setImageUrl:[[self.dict_data objectForKey:@"userDetails"] objectForKey:@"picURL"]];
		if ([self.degree isEqualToString:@"YES"]) {
			lblStatus.text =@"Out Of Knit";
			[img_wannahang setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_OutOfKnit")]];
		}else {
			lblStatus.text = @"In Knit";
			img_wannahang.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_InKnit")];
		}
		
		
		return cell;
		//	[cell.contentView insertSubview:photoImageView atIndex:0 ];
		
	}else if ([strLabel isEqualToString:@"SpouseCell"]) {
		NSString *Identifier = @"SpouseCell";
		cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
	
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(30, 12, 200, 20)];
			lblFirstName.tag = 16; 
			[lblFirstName setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			lblFirstName.font = [UIFont systemFontOfSize:14];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
			
		}
		
		UILabel *lblFirstName = (UILabel *)[cell.contentView viewWithTag:16];
		
		if ([[self.dict_data objectForKey:@"spouseDetails"] objectForKey:@"firstName"] && [[self.dict_data objectForKey:@"spouseDetails"] objectForKey:@"lastName"]) {
			lblFirstName.text = [NSString stringWithFormat:@"%@ %@",[[self.dict_data objectForKey:@"spouseDetails"] objectForKey:@"firstName"],[[self.dict_data objectForKey:@"spouseDetails"] objectForKey:@"lastName"]];
		}
		return cell;
		
	}
	else if([strLabel isEqualToString:@"TykeCell"]) {
		NSString *Identifier = @"TykeCell";
		cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleGray;
			if (![[self.dict_data objectForKey:@"DegreeCode"] isEqualToString:@"0"]) {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			
			
			UILabel *lblFirstName = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, 100, 20)];
			lblFirstName.tag = 16; 
			[lblFirstName setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			lblFirstName.backgroundColor = [UIColor clearColor];
			lblFirstName.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			lblFirstName.font = [UIFont boldSystemFontOfSize:14];
			[cell.contentView addSubview:lblFirstName];
			[lblFirstName release];
			
			UILabel *lbl_childAge = [[UILabel alloc]initWithFrame:CGRectMake(140, 26, 100, 20)];
			[lbl_childAge setTag:18];
			[lbl_childAge setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			[lbl_childAge setBackgroundColor:[UIColor clearColor]];
			lbl_childAge.font = [UIFont fontWithName:@"helvetica Neue" size:13];
			[lbl_childAge setFont:[UIFont boldSystemFontOfSize:13]];
			[cell.contentView addSubview:lbl_childAge];
			[lbl_childAge release];
		}
		
		UILabel *lbl_Name = (UILabel*)[cell viewWithTag:16];
		UILabel *lbl_childAge = (UILabel *)[cell viewWithTag:18];
		
		NSDictionary *CurrentKid = [[self.dict_data objectForKey:@"Kids"] objectAtIndex:indexPath.row];

		
		if ([CurrentKid objectForKey:@"firstName"] && [CurrentKid objectForKey:@"lastName"]) {
			lbl_Name.text = [NSString stringWithFormat:@" %@ %@",[CurrentKid objectForKey:@"firstName"],[CurrentKid objectForKey:@"lastName"]];
		}

		if ([CurrentKid objectForKey:@"DOB"]) {
			
			NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
			[formatter setDateFormat:@"yyyy-MM-dd"];
			NSDate *DOB = [formatter dateFromString:[CurrentKid objectForKey:@"DOB"]];
			lbl_childAge.text =  [NSString stringWithFormat:@"(%@)",getChildAgeFromDate(DOB)];
			if ([[[[self.dict_data objectForKey:@"Kids"] objectAtIndex:indexPath.row] objectForKey:@"gender"] isEqualToString:@"M"]) {
				lbl_childAge.textColor = BoyBlueColor;
			}else {
				lbl_childAge.textColor = GirlPinkColor;
			}
			[formatter release];
		}
		
		if ([[CurrentKid objectForKey:@"status"] isEqualToString:@"t"]) {
				lbl_Name.textColor = WannaHangColor;
		}
		
		CGSize aSize = [lbl_childAge.text sizeWithFont:lbl_childAge.font constrainedToSize:CGSizeMake(150, 34) lineBreakMode:lbl_childAge.lineBreakMode];
		
		int nameWidth = 260 - (aSize.width +10);
		
		CGSize aSizeName = [lbl_Name.text sizeWithFont:lbl_Name.font constrainedToSize:CGSizeMake(nameWidth, 34) lineBreakMode:lbl_Name.lineBreakMode];
		
		lbl_Name.frame = CGRectMake(20, (44 - aSizeName.height)/2, aSizeName.width, aSizeName.height);
		lbl_childAge.frame = CGRectMake(lbl_Name.frame.origin.x+lbl_Name.frame.size.width+3, (44 - aSize.height)/2, aSize.width, aSize.height);
		
		return cell;
	}	else if([strLabel isEqualToString:@"ButtonCell"]) {
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
		[btn_cell setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"btn_planPlaydate2.png")] forState:UIControlStateNormal];
		return cell;
	}else if([strLabel isEqualToString:@"CommonCell"]) {
		NSString *identifier = @"CommonCell";
		cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
		
		UIView *vi_header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 80, 20)];
		UILabel *lbl_header = [[UILabel alloc]initWithFrame:CGRectMake(25, 0, 80, 20)];
		[lbl_header setFont:[UIFont boldSystemFontOfSize:14]];
		[lbl_header setTextColor:[UIColor darkGrayColor]];
		
		if ([strLabel isEqualToString:@"TykeCell"]) {
			[lbl_header setText:@"Tykes"];	
		}else if ([strLabel isEqualToString:@"SpouseCell"]) {
			[lbl_header setText:@"Spouse"];	
		}else if ([strLabel isEqualToString:@"CommonCell"]) {
			[lbl_header setText:@"Common"];	
		}
		[lbl_header setBackgroundColor:[UIColor clearColor]];
		[vi_header addSubview:lbl_header];
		[lbl_header release];
		
		return [vi_header autorelease];	
	}else return nil;
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	if ([[[self.dict_data objectForKey:@"spouseDetails"] allKeys] count]) {
		return 5;
	}
	return 4;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	NSString *strLabel = [self getSectionLabelForSection:section];
	if ([strLabel isEqualToString:@"TykeCell"] ) {
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
		
		if (![[self.dict_data objectForKey:@"DegreeCode"] isEqualToString:@"0"]) {
			UIImage *currentImage = [self captureScreen];
			[self pushingViewController:currentImage];
			NSDictionary *kidDict = [[self.dict_data objectForKey:@"Kids"] objectAtIndex:indexPath.row];
			KidsListDetailViewController *kidsListDetailViewController = [[KidsListDetailViewController alloc]initWithNibName:@"KidsListDetailViewController" bundle:nil];
			kidsListDetailViewController.child_id = [kidDict objectForKey:@"id"];

			if ([[kidDict objectForKey:@"txtWannaHang"] isEqualToString:@"f"]) {
				kidsListDetailViewController.isWannaHang = NO;
			}else {
				kidsListDetailViewController.isWannaHang = YES;
			}
			
			kidsListDetailViewController.prevContImage = currentImage;
			[self.navigationController pushViewController:kidsListDetailViewController animated:NO];
			[kidsListDetailViewController release];
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
		}
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
	if ([strLabel isEqualToString:@"ButtonCell"]) {
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

										  
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag = 300) {
		[self popViewController];
		//		[DELEGATE userLoggedInWithDict:self.dict_loginInfo];
	}
}

- (void)dealloc {
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}

@end
