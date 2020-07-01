//
//  PlaydateNotificationViewController.m
//  TykeKnit
//
//  Created by Ver on 27/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PlaydateNotificationViewController.h"
#import "Global.h"

@implementation PlaydateNotificationViewController
@synthesize theTableView,arr_Data;



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	UIButton *btn_back = [DELEGATE getBackBarButton];
	[btn_back addTarget:self action:@selector(backPressed:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_back] autorelease];
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleView];
	self.theTableView.backgroundColor = [UIColor clearColor];
	self.arr_Data = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"playdateRequests" ofType:@"plist"]];
		
    [super viewDidLoad];
}

- (void) backPressed:(id) sender {
	[self popViewController];
	
}
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 90;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	UITableViewCell *cell;
	
	cell  = [tableView dequeueReusableCellWithIdentifier:@"section 0"];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"section 0"] autorelease];
	}
	cell.textLabel.text = [[self.arr_Data objectAtIndex:indexPath.row] objectForKey:@"comment_text"];
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
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
