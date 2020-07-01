//
//  MyFriendsViewController.m
//  TykeKnit
//
//  Created by Ver on 11/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyFriendsViewController.h"
#import "ParentDetailViewController.h"
#import "AddFriendsViewController.h"
#import "FriendsMainViewController.h"
#import "MyFriendsDetailViewController.h"
#import "TableCellImageView.h"
#import "JSON.h"
#import "TableCellImageView.h"

@implementation MyFriendsViewController
@synthesize theTableView,api_tyke,arr_friendsData;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void) viewWillAppear:(BOOL)animated {
	if ([[[DELEGATE window] subviews] containsObject:[DELEGATE nav_wannaHangBar].view]) {
		[[DELEGATE nav_wannaHangBar].view removeFromSuperview];
	}
	
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_dashBoard3 aboveSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_dashboard_wannaHang belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_dashBoard1 belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_dashBoard2 belowSubview:[DELEGATE vi_sideView].img_back];
	[super viewWillAppear:animated];

}
- (void)viewDidLoad {
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Friends"];
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	[self.navigationItem setHidesBackButton:YES];
	
	
	self.arr_friendsData = [[NSMutableArray alloc]init];
	if (!api_tyke) {
		api_tyke = [[TykeKnitApi alloc]init];
		api_tyke.delegate = self;
	}
	[DELEGATE addLoadingView:self.vi_main];
	[api_tyke getFriends];
	
    [super viewDidLoad];
}

- (void)addFriendsClicked {
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];

//	FriendsMainViewController *frdsVC = [[FriendsMainViewController alloc] initWithNibName:@"FriendsMainViewController" bundle:nil ];
//	frdsVC.prevContImage = currentImage;
//	[self.navigationController pushViewController:frdsVC animated:NO];
//	[frdsVC release];
	
	
	AddFriendsViewController *frdsVC = [[AddFriendsViewController alloc] initWithNibName:@"AddFriendsViewController" bundle:nil ];
	frdsVC.prevContImage = currentImage;
	[self.navigationController pushViewController:frdsVC animated:NO];
	[frdsVC release];
	
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0) {
		return 44;
	}
	return 55;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if (section ==0)
		return 1;
	return [self.arr_friendsData count];	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	//int rowInd = [indexPath row];
	if (indexPath.section == 0) {
		NSString *userInfoCell = @"addFriendsCell";
		cell = [tableView dequeueReusableCellWithIdentifier:userInfoCell];
		if (cell == nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:userInfoCell] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		//	cell.editingStyle = UITableViewCellEditingStyleInsert;
			
			UIButton *btn_addFrinds = [UIButton buttonWithType:UIButtonTypeContactAdd];
			[btn_addFrinds setFrame:CGRectMake(10, 10, 25, 25)];
			[btn_addFrinds addTarget:self action:@selector(addFriendsClicked) forControlEvents:UIControlEventTouchUpInside];
			[cell.contentView addSubview:btn_addFrinds];
			
			UILabel *lbl_addFriends = [[UILabel alloc]initWithFrame:CGRectMake(55, 12, 150, 20)];
			lbl_addFriends.tag = 1;
			[lbl_addFriends setText:@"Add More Friends"];
			[lbl_addFriends setTextColor:[UIColor grayColor]];
			[cell.contentView addSubview:lbl_addFriends];
			[lbl_addFriends release];
		}
			return cell;
	}else if (indexPath.section == 1) {
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
			
			TableCellImageView *img_KidPic = [[TableCellImageView alloc]initWithFrame:CGRectMake(15, 3, 45, 45)];
			img_KidPic.defaultImage = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
			img_KidPic.tag = 1;
			[cell.contentView addSubview:img_KidPic];
			[img_KidPic release];
			
			UIImageView *img_wannahang = [[UIImageView alloc]initWithFrame:CGRectMake(65, 7, 18, 18)];
			img_wannahang.tag = 4;
			img_wannahang.backgroundColor = [UIColor clearColor];
//			img_wannahang.image = [UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"userStatus_InKnit.png")];
			[cell.contentView addSubview:img_wannahang];
			[img_wannahang release];
			
			UILabel *lbl_Name = [[UILabel alloc]initWithFrame:CGRectMake(93, 9, 140, 15)];
			lbl_Name.backgroundColor = [UIColor clearColor];
			lbl_Name.text = @"user 1";
			lbl_Name.font = [UIFont fontWithName:@"helvetica Neue" size:14];
			lbl_Name.font = [UIFont boldSystemFontOfSize:14];
			lbl_Name.textColor = [UIColor darkGrayColor];
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
		TableCellImageView *img_KidPic = (TableCellImageView *)[cell viewWithTag:1];
		UILabel *lbl_Name = (UILabel *)[cell viewWithTag:2];
		UIImageView *img_wannahang = (UIImageView *)[cell viewWithTag:4];
		
		NSDictionary *dictData = [self.arr_friendsData objectAtIndex:indexPath.row];
		
		//	img_KidPic.image = [UIImage imageNamed:[dictData objectForKey:@"PhotoUrl"]];
		[img_KidPic setImageUrl:[dictData objectForKey:@"picURL"]];
		//img_KidPic.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
		img_wannahang.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_InKnit")];
		//if ([dictData objectForKey:@"picURL"]) {
		//	img_KidPic.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[dictData objectForKey:@"picURL"]]]];
		//}
		if ([dictData objectForKey:@"firstName"] && [dictData objectForKey:@"lastName"]) {
			lbl_Name.text = [NSString stringWithFormat:@"%@ %@",[dictData objectForKey:@"firstName"],[dictData objectForKey:@"lastName"]];
		}

		CGSize aSize = [lbl_Name.text sizeWithFont:lbl_Name.font constrainedToSize:CGSizeMake(150, 32) lineBreakMode:lbl_Name.lineBreakMode];
		
		int yAxics = (55 - aSize.height)/2;
		lbl_Name.frame = CGRectMake( 85, yAxics, 150, aSize.height);
		
		img_wannahang.frame = CGRectMake(63, (55-18)/2, 18, 18);
		
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
		[self addFriendsClicked];
	}else if (indexPath.section == 1) {
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		
        /****************************************************************************** 
         * Change by Manish             START
         ******************************************************************************/  
        /*
		MyFriendsDetailViewController *details = [[MyFriendsDetailViewController alloc]initWithNibName:@"MyFriendsDetailViewController" bundle:nil];
		details.prevContImage = currentImage;
		details.friendId = [[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"id"];
		details.degree = [[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"FriendOfFriend"];
        */
        ParentDetailViewController *details = [[ParentDetailViewController alloc]initWithNibName:@"ParentDetailViewController" bundle:nil];
        details.prevContImage = currentImage;
        details.parent_ID = [[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"id"];
        details.degree_code =[[self.arr_friendsData objectAtIndex:indexPath.row] objectForKey:@"DegreeCode"];
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
	[api_tyke cancelCurrentRequest];
	[self.arr_friendsData release];
	[api_tyke release];
	
    [super dealloc];
}


@end
