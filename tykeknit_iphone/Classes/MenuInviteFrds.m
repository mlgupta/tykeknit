//
//  MenuInviteFrds.m
//  TykeKnit
//
//  Created by Abhinit Tiwari on 18/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuInviteFrds.h"
#import "VXTTableCellBackground.h"
#import "InviteFriendsEmailViewController.h"
#import "AddFacebookFriendsViewController.h"
#import "FBViewController.h"
#import "FriendsMainViewController.h"
#import "AddAddressbookFriendsViewController.h"

@implementation MenuInviteFrds
@synthesize menuTable,arrMenuNames,arrImgMenuNames;


- (void)viewDidLoad {
	
	self.arrMenuNames = [[NSMutableArray alloc] init];
	[self.arrMenuNames addObject:@"Address Book"];
	[self.arrMenuNames addObject:@"Facebook"];
	[self.arrMenuNames addObject:@"Email"];

	self.arrImgMenuNames = [[NSMutableArray alloc] init];
	[self.arrImgMenuNames addObject:@"addressBook.png"];
	[self.arrImgMenuNames addObject:@"facebook.png"];
	[self.arrImgMenuNames addObject:@"email.png"];
	
	
    [super viewDidLoad];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	return 3;	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *CellIdentifier = @"PartnerCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; 
		
		VXTTableCellBackground *v1 = [[[VXTTableCellBackground alloc] initWithFrame:CGRectZero] autorelease];
		[v1 setBackgroundColor:[UIColor clearColor]];
		cell.backgroundView = v1;

		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5,5,30,30)]; 
		imageView.tag = 300;
		[cell.contentView addSubview:imageView];
		[imageView release];
		
		
		UILabel *lblMenu = [[UILabel alloc] initWithFrame:CGRectMake(40, 7, 150, 20) ];
		lblMenu.backgroundColor = [UIColor clearColor];
		lblMenu.font = [UIFont boldSystemFontOfSize:13];
		lblMenu.tag = 200;
		[cell.contentView addSubview:lblMenu];
		[lblMenu release];
		
		
	}
	((UIImageView*)[cell viewWithTag:300]).image = [UIImage imageNamed:[self.arrImgMenuNames objectAtIndex:[indexPath row]]];
	
	((UILabel*)[cell viewWithTag:200]).text = [self.arrMenuNames objectAtIndex:[indexPath row]];
	if ([indexPath row] == 0) {
		[(VXTTableCellBackground *)cell.backgroundView setPosition:VXTTableCellBackgroundViewPositionTop];
	}else if([indexPath row] == 1) {
		[(VXTTableCellBackground *)cell.backgroundView setPosition:VXTTableCellBackgroundViewPositionMiddle];
	}else {
		[(VXTTableCellBackground *)cell.backgroundView setPosition:VXTTableCellBackgroundViewPositionBottom];
	}
	
	return cell;
}
				
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	
		if ([indexPath row] == 0) {
			//FriendsMainViewController *frdsVC = [[FriendsMainViewController alloc] initWithNibName:@"FriendsMainViewController" bundle:nil ];
//			[self.navigationController pushViewController:frdsVC animated:YES];
			AddAddressbookFriendsViewController *addressBook = [[AddAddressbookFriendsViewController alloc] initWithNibName:@"AddAddressbookFriendsViewController" bundle:nil];
			[self.navigationController pushViewController:addressBook animated:YES];
			[addressBook release];
		}
		if ([indexPath row] == 1) {
			FBViewController *fbVC = [[FBViewController alloc] initWithNibName:@"FBViewController" bundle:nil];
			[self.navigationController pushViewController:fbVC animated:YES];
			[fbVC release];
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	
		if([indexPath row] == 2){
//			emailComposeVC *emailView = [[emailComposeVC alloc] initWithNibName:@"emailComposeVC" bundle:nil];
//			[self.navigationController pushViewController:emailView animated:YES];
//			[emailView release];
		}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[self.arrMenuNames release];
    [super dealloc];
}


@end
