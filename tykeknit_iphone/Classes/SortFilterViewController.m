//
//  SortFilterViewController.m
//  SpotWorld
//
//  Created by Abhinav Singh on 30/09/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "SortFilterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Global.h"
#import "VXTTableCellBackground.h"


@implementation SortFilterViewController
@synthesize arr_Categories, theTableView, arr_SelectedCat, arr_neighbourHoods, arr_SelectedNeighbours;

- (void) cancelPressed : (id) sender {
	[self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableDictionary*) getSortDictionary {
	
	NSMutableDictionary *dictSort = [[NSMutableDictionary alloc] init];
	NSString *str_Category = [self.arr_SelectedCat componentsJoinedByString:@";"];
	str_Category = [str_Category stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	if (isValidString(str_Category)) {
		[dictSort setObject:str_Category forKey:@"filter_tag"];
	}
	
	NSString *str_Neigh = @"";
	for (NSDictionary *dictNeigh in self.arr_SelectedNeighbours) {
		str_Neigh = [str_Neigh stringByAppendingFormat:@"%@;", [dictNeigh objectForKey:@"index"]];
	}
	
	if (isValidString(str_Neigh)) {
		[dictSort setObject:str_Neigh forKey:@"filter_neighborhood"];
	}
	
	if (![[dictSort allKeys] count]) {
		[dictSort release];
		return nil;
	}
	
	[dictSort setObject:@"asc" forKey:@"sort_order"];
	int indexSort = [(UISegmentedControl*)[self.view viewWithTag:171] selectedSegmentIndex];
	
	if (indexSort == 0) {
		[dictSort setObject:@"distance" forKey:@"orderby"];
	}else if(indexSort == 1)  {
		[dictSort setObject:@"Price" forKey:@"orderby"];
	}else if(indexSort == 2)  {
		[dictSort setObject:@"AverageRating" forKey:@"orderby"];
	}

	return [dictSort autorelease];
}

- (void) viewDidLoad {
	
	self.arr_Categories = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SearchCategory" ofType:@"plist"]];
	self.arr_neighbourHoods = [[NSMutableArray alloc] init];
	self.arr_SelectedNeighbours = [[NSMutableArray alloc] init];
	NSDictionary *dictNeigh = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Neighbourhoods" ofType:@"plist"]];
	
	for (NSString *key in [dictNeigh allKeys]) {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
		[dict setObject:key forKey:@"index"];
		[dict setObject:[dictNeigh objectForKey:key] forKey:@"value"];
		[self.arr_neighbourHoods addObject:dict];
		[self.arr_SelectedNeighbours addObject:dict];
		[dict release];
	}
	
	self.arr_SelectedCat = [[NSMutableArray alloc] init];
//	self.navigationItem.titleView = [DELEGATE getTitleView:@"Sort / Filter"];
	UIBarButtonItem *itemCancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self 
																   action:@selector(cancelPressed:)];
	self.navigationItem.leftBarButtonItem = itemCancel;
	[itemCancel release];
	
	self.theTableView.separatorColor = [UIColor colorWithRed:0.229 green:0.616 blue:0.79 alpha:1];
	[super viewDidLoad];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int section = [indexPath section];
	int rowIndex = [indexPath row];
	NSString *searchCell = @"searchCell";
	UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:searchCell];
	if(cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCell] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.backgroundColor = [UIColor clearColor];
		
		VXTTableCellBackground *v1 = [[[VXTTableCellBackground alloc] initWithFrame:CGRectZero] autorelease];
		[v1 setBackgroundColor:[UIColor clearColor]];
		cell.backgroundView = v1;
		
//		cell.backgroundColor = [UIColor clearColor];
		
	/*	UIView *viBack = [[UIView alloc] initWithFrame:CGRectZero];
		viBack.backgroundColor = [UIColor whiteColor];
		viBack.layer.cornerRadius = 12.0f;
		cell.backgroundView = viBack;
		[viBack release];*/

		UILabel *lbl_heading = [[UILabel alloc] initWithFrame:CGRectMake( 10, 10, 250, 24)];
		lbl_heading.tag = 115;
		lbl_heading.textAlignment = UITextAlignmentLeft;
		lbl_heading.textColor = [UIColor blackColor];
		lbl_heading.font = [UIFont boldSystemFontOfSize:14];
		lbl_heading.backgroundColor = [UIColor clearColor];
		[cell.contentView addSubview:lbl_heading];
		[lbl_heading release];
	}
	
	
	UILabel *lbl_heading = (UILabel*)[cell viewWithTag:115];
	
	if (section == 0) {
		NSString *strCurrent = [self.arr_Categories objectAtIndex:rowIndex];
		lbl_heading.text = strCurrent;
		
		if ([self.arr_SelectedCat containsObject:strCurrent]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			[(VXTTableCellBackground *)cell.backgroundView setViewStyle:VXTTableCellBackgroundViewStyleHighlighted];
		}else {
			cell.accessoryType = UITableViewCellAccessoryNone;
			[(VXTTableCellBackground *)cell.backgroundView setViewStyle:VXTTableCellBackgroundViewStyleNormal];
		}
		
		if (rowIndex == 0) {
			[(VXTTableCellBackground *)cell.backgroundView setPosition:VXTTableCellBackgroundViewPositionTop];
		}else if([self.arr_Categories count] == rowIndex+1) {
			[(VXTTableCellBackground *)cell.backgroundView setPosition:VXTTableCellBackgroundViewPositionBottom];
		}else {
			[(VXTTableCellBackground *)cell.backgroundView setPosition:VXTTableCellBackgroundViewPositionMiddle];
		}
		
	}else if (section == 1) {
		
		NSDictionary *dictCurrent = [self.arr_neighbourHoods objectAtIndex:rowIndex];
		lbl_heading.text = [dictCurrent objectForKey:@"value"];
		
		if ([self.arr_SelectedNeighbours containsObject:dictCurrent]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			[(VXTTableCellBackground *)cell.backgroundView setViewStyle:VXTTableCellBackgroundViewStyleHighlighted];
		}else {
			cell.accessoryType = UITableViewCellAccessoryNone;
			[(VXTTableCellBackground *)cell.backgroundView setViewStyle:VXTTableCellBackgroundViewStyleNormal];
		}
		
		if (rowIndex == 0) {
			[(VXTTableCellBackground *)cell.backgroundView setPosition:VXTTableCellBackgroundViewPositionTop];
		}else if([self.arr_SelectedNeighbours count] == rowIndex+1) {
			[(VXTTableCellBackground *)cell.backgroundView setPosition:VXTTableCellBackgroundViewPositionBottom];
		}else {
			[(VXTTableCellBackground *)cell.backgroundView setPosition:VXTTableCellBackgroundViewPositionMiddle];
		}
	}
	
	return cell;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	if (section == 0) {
		return [self.arr_Categories count];
	}else if (section == 1) {
	 	return [self.arr_neighbourHoods count];
	}
	
	return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	int section = [indexPath section];
	int rowIndex = [indexPath row];
	
	if (section == 0) {
		NSString *strCurrent = [self.arr_Categories objectAtIndex:rowIndex];
		if ([self.arr_SelectedCat containsObject:strCurrent]) {
			[self.arr_SelectedCat removeObject:strCurrent];
		}else {
			[self.arr_SelectedCat addObject:strCurrent];
		}
	}else {
		NSDictionary *dictCurrent = [self.arr_neighbourHoods objectAtIndex:rowIndex];
		if ([self.arr_SelectedNeighbours containsObject:dictCurrent]) {
			[self.arr_SelectedNeighbours removeObject:dictCurrent];
		}else {
			[self.arr_SelectedNeighbours addObject:dictCurrent];
		}
	}
	
	[tableView reloadData];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return 30.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *vi = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
	vi.backgroundColor = [UIColor clearColor];
	
	UILabel *lbl_head = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 280, 30)];
	lbl_head.font = [UIFont boldSystemFontOfSize:15];
	lbl_head.backgroundColor = [UIColor clearColor];
	lbl_head.textColor = [UIColor blackColor];
	lbl_head.shadowColor = [UIColor whiteColor];
	lbl_head.shadowOffset = CGSizeMake( 0, 1);
	[vi addSubview:lbl_head];
	[lbl_head release];
	
	if (section == 0) {
		lbl_head.text = @"Categories";
	}else {
		lbl_head.text = @"Neighborhoods";
	}

	return [vi autorelease];
}

- (void)dealloc {
	
	[self.arr_Categories release];
	[self.theTableView release];
	[self.arr_SelectedCat release];
	
	[self.arr_neighbourHoods release];
	[self.arr_SelectedNeighbours release];
	[super dealloc];
}


@end
