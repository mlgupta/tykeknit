//
//  TermsAndCondView.m
//  TykeKnit
//
//  Created by Abhinit Tiwari on 07/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TermsAndCondView.h"
#import "UserRegStepOne.h"

@implementation TermsAndCondView
@synthesize objScrollView;

- (float) getSizeOfString : (NSString*)str {
	
	CGSize aSize = [str sizeWithFont:[UIFont systemFontOfSize:12] 
				   constrainedToSize:CGSizeMake(270, FLT_MAX) 
					   lineBreakMode:UILineBreakModeWordWrap];
	return aSize.height;
}


- (void)viewDidLoad {

	UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 300, 30)];
	lblTitle.font = [UIFont boldSystemFontOfSize:13];
	lblTitle.text = @"Terms of Use and Privacy Policy";
	lblTitle.backgroundColor = [UIColor clearColor];
	[self.objScrollView addSubview:lblTitle];
	[lblTitle release];
		
	UILabel *lblOverview = [[UILabel alloc] initWithFrame:CGRectMake(20, 25, 100, 30)];
	lblOverview.font = [UIFont systemFontOfSize:12];
	lblOverview.text = @"OVERVIEW";
	lblOverview.backgroundColor = [UIColor clearColor];
	[self.objScrollView addSubview:lblOverview];
	[lblOverview release];
		
	NSString *text = [NSString stringWithFormat:@"Welcome to the TykeKnit, Inc.(\"TykeKnit\", \"We\", \"Our\") mobile device software application (the \"TykeKnit App\"),	Website , web widgets, feeds and application for third-party Websites and services, and any other mobile or web services or applications owned, controlled, or offered by TykeKnit Inc., (collectively, the \"TykeKnit Services\").\n\nTykeKnit's goal is to connect parents to enable them to plan playmates and activities for their kids through a network of trussed relationships. To achieve our Mission, we make services available through our website, mobile applications, and developer platforms rents and kids meet, schedule play-dates, learn, find family-friendly events, find friends, help kids have a fulfilling and fun childhood,  and help parents meet other parents.  TykeKnit takes privacy and security very seriously , and it compiles with the TRUSTe's Privacy Standards and the Children's Online Privacy Protection Act (COPPA)."];;	
	float h = [self getSizeOfString:text];
	UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 270, h)];
	lblText.font = [UIFont systemFontOfSize:11];
	
	lblText.backgroundColor = [UIColor clearColor];
	lblText.numberOfLines = 0;
	
	lblText.text = @"Welcome to the TykeKnit, Inc.(\"TykeKnit\", \"We\", \"Our\") mobile device software application (the \"TykeKnit App\"),	Website , web widgets, feeds and application for third-party Websites and services, and any other mobile or web services or applications owned, controlled, or offered by TykeKnit Inc., (collectively, the \"TykeKnit Services\").\n\nTykeKnit's goal is to connect parents to enable them to plan playmates and activities for their kids through a network of trussed relationships. To achieve our Mission, we make services available through our website, mobile applications, and developer platforms rents and kids meet, schedule play-dates, learn, find family-friendly events, find friends, help kids have a fulfilling and fun childhood,  and help parents meet other parents.  TykeKnit takes privacy and security very seriously , and it compiles with the TRUSTe's Privacy Standards and the Children's Online Privacy Protection Act (COPPA).";
	
	[self.objScrollView addSubview:lblText];
	[lblText release];
    [super viewDidLoad];
}

- (void) funBackButtonClicked : (id) sender {
	//[self.view removeFromSuperview];
//	UserRegStepOne *userRegStepOne = [[UserRegStepOne alloc] initWithNibName:@"UserRegStepOne" bundle:nil];
//	[self.view addSubview:userRegStepOne.view];
	[self.navigationController popViewControllerAnimated:YES];

	
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
    [super dealloc];
}


@end
