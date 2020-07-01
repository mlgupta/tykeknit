//
//  userAuthentication.m
//  TykeKnit
//
//  Created by Ver on 22/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "userAuthentication.h"
#import "JSON.h"
#import "Global.h"


@implementation userAuthentication
@synthesize theTableView,dict_loginInfo;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Verification"];
	
	UIButton *btn_Back = [DELEGATE getBackBarButton];
	[btn_Back addTarget:self action:@selector(backClicked:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_Back] autorelease];
	
	api_tyke = [[TykeKnitApi alloc] init];
	api_tyke.delegate = self;
	//	self.rightSideView = [[UIImageView alloc] initWithFrame:CGRectMake(280, 0, 45, 418)];
	//	[self.rightSideView setBackgroundColor:[UIColor clearColor]];
	//	[self.rightSideView setImage:[[UIImage imageNamed:@"tab_grad.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:22]];
	//	[self.rightSideView setAlpha:0.5];
	//	[self.view addSubview:self.rightSideView];
	//	[self.rightSideView release];
	
	[self.theTableView setBackgroundView:[[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"img_background")]] autorelease]];
	[self.view setBackgroundColor:[UIColor blackColor]];
    [super viewDidLoad];
}

- (void) backClicked : (id) sender {
	[self popViewController];
    [DELEGATE logOutCurrentUser];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 2;//[self.dictTykeData count]*3;
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
	if (indexPath.section==0) {
		return 145;	
	}
	return 40;
	
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	UIView *vi = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 50)] autorelease];
	if(section == 0){
		
		UIImageView *img_info = [[UIImageView alloc]initWithFrame:CGRectMake(42, 23, 23, 23)];
		//	[img_info setImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"spouse_info.png")]];
		[vi addSubview:img_info];
		[img_info release];
		
		UILabel *headerName = [[UILabel alloc] initWithFrame:CGRectMake(30, 23, 160, 20)];
		headerName.textAlignment = UITextAlignmentLeft;
		headerName.textColor = [UIColor darkGrayColor];
		headerName.text = @"Verification";
		[headerName setFont:[UIFont fontWithName:@"helvetica Neue Thin" size:15]];
		headerName.backgroundColor = [UIColor clearColor];
		[vi addSubview:headerName];
		[headerName release];
	}
	return vi;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *CellIdentifier = @"EmailCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
		
		UILabel *lbl_info = [[UILabel alloc]initWithFrame:CGRectMake(20, 10, 260, 125)];
		lbl_info.tag = 1;
		[lbl_info setFont:[UIFont fontWithName:@"helvetica Neue" size:13]];
		[lbl_info setTextColor:[UIColor darkGrayColor]];
		[lbl_info setBackgroundColor:[UIColor clearColor]];
		[lbl_info setNumberOfLines:0];
		[lbl_info setText:@"Unable to proceed further until your account is verified. Please verify your account by clicking on the link we sent to you.  If you want us to send you a new verification link, please provide the email address you used to register with TykeKnit."];
		[cell.contentView addSubview:lbl_info];
		[lbl_info release];
		
		UIButton *btn_Retrive = [UIButton buttonWithType:UIButtonTypeCustom];
		btn_Retrive.frame = CGRectMake(-5, 0, 310, 40);
		[btn_Retrive setBackgroundImage:[UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"default_tykeknit_button.png")] forState:UIControlStateNormal];
		[btn_Retrive setTitle:@"Send Verification Link" forState:UIControlStateNormal];
		[btn_Retrive addTarget:self action:@selector(btn_RetreivePasswordPressed:) forControlEvents:UIControlEventTouchUpInside];
		btn_Retrive.titleLabel.font = [UIFont boldSystemFontOfSize:17];
		btn_Retrive.tag = 2;
		[cell.contentView addSubview:btn_Retrive];
	}
	
	UILabel *lbl_info = (UILabel *)[cell.contentView viewWithTag:1];
	UIButton *btn_Retrive = (UIButton *)[cell.contentView viewWithTag:2];
	
	lbl_info.hidden = YES;
	btn_Retrive.hidden = YES;
	
	switch (indexPath.section) {
		case 0:
			lbl_info.hidden = NO;
			break;
		case 1:
			btn_Retrive.hidden = NO;
		default:
			break;
	}
	return cell;
}
- (void) btn_RetreivePasswordPressed : (id) sender {
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke resendConfirmationURL];
}
- (void) confirmationURLResponse : (NSData *) data {
	NSDictionary *response = [[data stringValue] JSONValue];
	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Thank You" 
													   message:@"Account verification link has been sent to you by email."
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
//		[DELEGATE userLoggedInWithDict:self.dict_loginInfo];
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


- (void)dealloc {
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}


@end
