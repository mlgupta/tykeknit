//
//  UserRegSpouseInfo.m
//  TykeKnit
//
//  Created by Ver on 14/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserRegSpouseInfo.h"

@implementation UserRegSpouseInfo
@synthesize theTableView,rightSideView;

- (void)viewDidLoad {
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Invite"];

	UIButton *btn_Back = [DELEGATE getBackBarButton];
	[btn_Back addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_Back] autorelease];

//	self.rightSideView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 0, 45, 418)];
//	[self.rightSideView setBackgroundColor:[UIColor clearColor]];
//	[self.rightSideView setImage:[[UIImage imageNamed:@"tab_grad.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:22]];
//	[self.rightSideView setAlpha:0.5];
//	[self.view addSubview:self.rightSideView];
//	[self.rightSideView release];
	
	[self.theTableView setBackgroundView:[[[UIImageView alloc]initWithImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"registeration_background.png")]] autorelease]];
	[self.view setBackgroundColor:[UIColor blackColor]];
    [super viewDidLoad];
}

- (void) backClicked : (id) sender {
	[self popViewController];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;//[self.dictTykeData count]*3;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return 50;
	}
	
	return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 110;	
	
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 50)] autorelease];
	if(section == 0){
		
		UIImageView *img_info = [[UIImageView alloc]initWithFrame:CGRectMake(42, 23, 23, 23)];
		[img_info setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"spouse_info.png")]];
		[vi addSubview:img_info];
		[img_info release];
		
		UILabel *headerName = [[UILabel alloc] initWithFrame:CGRectMake(70, 23, 160, 20)];
		headerName.textAlignment = UITextAlignmentLeft;
		headerName.textColor = [UIColor darkGrayColor];
		headerName.text = @"Spouse Email";
		[headerName setFont:[UIFont fontWithName:@"helvetica Neue Thin" size:15]];
		headerName.backgroundColor = [UIColor clearColor];
		[vi addSubview:headerName];
		[headerName release];
	}
	return vi;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	if (indexPath.section==0) {
		NSString *CellIdentifier = @"InfoCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
			cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
		
			UILabel *lbl_info = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 230, 90)];
			[lbl_info setFont:[UIFont fontWithName:@"helvetica Neue" size:12]];
			[lbl_info setTextColor:[UIColor darkGrayColor]];
			[lbl_info setBackgroundColor:[UIColor clearColor]];
			[lbl_info setNumberOfLines:0];
			[lbl_info setText:@"We request your spouse's email address so we can associate your tyke to his/her other parent.  This will create a 'family account' on TykeKnit allowing you both to plan fun activities for your tyke(s)."];
			[cell.contentView addSubview:lbl_info];
			[lbl_info release];
		}
		
		
		return cell;
	}
	return nil;
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
    [super dealloc];
}


@end
