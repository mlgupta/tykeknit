//
//  CommonFriendsViewController.m
//  TykeKnit
//
//  Created by Ver on 05/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CommonFriendsViewController.h"
#import "ParentDetailViewController.h"
#import "Global.h"
#import "MyFriendsDetailViewController.h"
#import "TableCellImageView.h"
#import "JSON.h"


@implementation CommonFriendsViewController
@synthesize theTableView,arr_friendsData;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void) viewWillAppear:(BOOL)animated {
	if ([[[DELEGATE window] subviews] containsObject:[DELEGATE nav_wannaHangBar].view]) {
		[[DELEGATE nav_wannaHangBar].view removeFromSuperview];
	}
	
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_playDateSearch aboveSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_playDate_send belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_wannaHang belowSubview:[DELEGATE vi_sideView].img_back];
	[super viewWillAppear:animated];
	
}

- (void) backClicked : (id) sender {
	[self popViewController];
}

- (void)viewDidLoad {
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Friends"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	[self.navigationItem setHidesBackButton:YES];
	
	UIButton *btn_Back = [DELEGATE getBackBarButton];
	[btn_Back addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_Back] autorelease];
	
    [super viewDidLoad];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
		return 44;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return [self.arr_friendsData count]-1;	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	//int rowInd = [indexPath row];
	if (indexPath.section == 0) {
		NSString *userInfoCell = @"FriendsInfoCell";
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			UIImageView *img_Back = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 280, 65)];
			img_Back.backgroundColor = [UIColor clearColor];
			img_Back.tag = 11;
			[cell.contentView addSubview:img_Back];
			[img_Back release];
			
//			TableCellImageView *img_KidPic = [[TableCellImageView alloc]initWithFrame:CGRectMake(15, 3, 45, 45)];
//			img_KidPic.defaultImage = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
//			img_KidPic.tag = 1;
//			[cell.contentView addSubview:img_KidPic];
//			[img_KidPic release];
			
//			UIImageView *img_wannahang = [[UIImageView alloc]initWithFrame:CGRectMake(65, 7, 18, 18)];
//			img_wannahang.tag = 4;
//			img_wannahang.backgroundColor = [UIColor clearColor];
//			//			img_wannahang.image = [UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"userStatus_InKnit.png")];
//			[cell.contentView addSubview:img_wannahang];
//			[img_wannahang release];
			
			UILabel *lbl_Name = [[UILabel alloc]initWithFrame:CGRectMake(20, 12, 140, 20)];
			lbl_Name.backgroundColor = [UIColor clearColor];
			lbl_Name.text = @"user 1";
			lbl_Name.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			lbl_Name.font = [UIFont boldSystemFontOfSize:14];
			[lbl_Name setTextColor:[UIColor colorWithRed:0.2196 green:0.3294 blue:0.5294 alpha:1.0]];
			lbl_Name.tag = 2;
			[cell.contentView addSubview:lbl_Name];
			[lbl_Name release];
			
			UILabel *lbl_Age = [[UILabel alloc]initWithFrame:CGRectMake(74, 23, 180, 30)];
			lbl_Age.backgroundColor = [UIColor clearColor];
			lbl_Age.numberOfLines = 0;
			lbl_Age.font = [UIFont fontWithName:@"helvetica Neue" size:12];
			lbl_Age.font = [UIFont boldSystemFontOfSize:12];
			lbl_Age.tag = 3;
			lbl_Age.textColor = [UIColor lightGrayColor];
			[cell.contentView addSubview:lbl_Age];
			[lbl_Age release];
			
		}			
		//	UIImageView *img_Back = (UIImageView *)[cell viewWithTag:11];
//		TableCellImageView *img_KidPic = (TableCellImageView *)[cell viewWithTag:1];
		UILabel *lbl_Name = (UILabel *)[cell viewWithTag:2];
		UIImageView *img_wannahang = (UIImageView *)[cell viewWithTag:4];
		
		NSDictionary *dictData = [self.arr_friendsData objectAtIndex:indexPath.row+1];
		
		//	img_KidPic.image = [UIImage imageNamed:[dictData objectForKey:@"PhotoUrl"]];
//		[img_KidPic setImageUrl:[dictData objectForKey:@"picURL"]];
		//img_KidPic.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
		img_wannahang.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_InKnit")];
		//if ([dictData objectForKey:@"picURL"]) {
		//	img_KidPic.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dictData objectForKey:@"picURL"]]]];
		//}
		if ([dictData objectForKey:@"fName"] && [dictData objectForKey:@"lName"]) {
			lbl_Name.text = [NSString stringWithFormat:@"%@ %@",[dictData objectForKey:@"fName"],[dictData objectForKey:@"lName"]];
		}
		
//		CGSize aSize = [lbl_Name.text sizeWithFont:lbl_Name.font constrainedToSize:CGSizeMake(150, 32) lineBreakMode:lbl_Name.lineBreakMode];
		
		
		return cell;
	}
	return nil;
}
- (void) getFriendsResponse : (NSData *)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		self.arr_friendsData  = [[response objectForKey:@"response"] objectForKey:@"Friends"];
		for (int i = 0;i < [self.arr_friendsData count];i++) {
			if ([[[self.arr_friendsData objectAtIndex:i] allKeys] count] < 2) {
				[self.arr_friendsData removeObjectAtIndex:i];
			}
		}
		[self.theTableView reloadData];
		
	}
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{  	
    if (indexPath.section == 0) {
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
        /****************************************************************************** 
         * Change by Manish             START
         ******************************************************************************/  
        /*
		MyFriendsDetailViewController *details = [[MyFriendsDetailViewController alloc]initWithNibName:@"MyFriendsDetailViewController" bundle:nil];
		details.prevContImage = currentImage;
		details.friendId = [[self.arr_friendsData objectAtIndex:indexPath.row+1] objectForKey:@"userTblPk"];
		details.degree = [[self.arr_friendsData objectAtIndex:indexPath.row+1] objectForKey:@"FriendOfFriend"];
         */

        ParentDetailViewController *details = [[ParentDetailViewController alloc]initWithNibName:@"ParentDetailViewController" bundle:nil];
        details.prevContImage = currentImage;
        details.parent_ID = [[self.arr_friendsData objectAtIndex:indexPath.row+1] objectForKey:@"userTblPk"];
        details.degree_code =[[self.arr_friendsData objectAtIndex:indexPath.row+1] objectForKey:@"DegreeCode"];
        details.spouseDetailsToShow = YES;

        /****************************************************************************** 
         * Change by Manish             END
         ******************************************************************************/  

		[self.navigationController pushViewController:details animated:NO];
		[details release];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
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
	[super dealloc];
}


@end
