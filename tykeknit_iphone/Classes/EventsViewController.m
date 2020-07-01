//
//  EventsViewController.m
//  TykeKnit
//
//  Created by Ver on 07/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EventsViewController.h"
#import "ComposeMailViewController.h"
#import "MessageDetailViewController.h"
#import "EventDetailViewController.h"
#import "CustomSegmentView.h"
#import "AddEventViewController.h"
#import "Global.h"
#import "JSON.h"

@implementation EventsViewController
@synthesize theTableView,api_tyke,arr_data,selectedIndexPath,swipeView,toReload,RemoveRow;
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void) viewWillAppear:(BOOL)animated {
	
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_events1 aboveSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_events2 belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_home belowSubview:[DELEGATE vi_sideView].img_back];
	
//	[DELEGATE addLoadingView:self.vi_main];
//	[api_tyke getEvents:@"0" txtResultOffset:@"0" txtResultLimit:@"30"];

	[super viewWillAppear:animated];
}

- (void)viewDidLoad {
	//shadow for Navigationbar

	CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.5f].CGColor;
	CGColorRef lightColor = [UIColor clearColor].CGColor;
	
	CAGradientLayer *newShadow = [[[CAGradientLayer alloc] init] autorelease];
	newShadow.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.width, 7);
	newShadow.colors = [NSArray arrayWithObjects:(id)darkColor, (id)lightColor, nil];
	[self.navigationController.navigationBar.layer addSublayer:newShadow];	
	
	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Events"];

	self.arr_data = [[NSMutableArray alloc]init];
	if (!api_tyke) {
		api_tyke = [[TykeKnitApi alloc]init];
		api_tyke.delegate = self;
	}

    if (_refreshHeaderView == nil) {
        EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f - self.theTableView.bounds.size.height, self.view.frame.size.width, self.theTableView.bounds.size.height)];
        view.delegate = self;
        [self.theTableView addSubview:view];
        _refreshHeaderView = view;
        [view release];
    }

	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
    [_refreshHeaderView refreshLastUpdatedDate];
	
    [self performSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:) withObject:self.view];

    [super viewDidLoad];
}

#pragma mark -
#pragma mark RightSideViewDelegate

- (void) buttonClickedNamed : (NSString*) name {
	if ([name isEqualToString:@"AllEvents"]) {
		for (UIViewController *viewCont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
        
		[self.navigationController popToRootViewControllerAnimated:NO];
		[[[self.navigationController viewControllers] objectAtIndex:0] viewWillAppear:NO];
	}else if([name isEqualToString:@"AddEvent"]) {
		for (UIViewController *viewCont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
		AddEventViewController *add_event = [[AddEventViewController alloc] initWithNibName:@"AddEventView" bundle:nil];
		[self.navigationController pushViewController:add_event animated:NO];
		[add_event release];
	}
}	
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource {
    [api_tyke getEvents:@"0" txtResultOffset:@"0" txtResultLimit:@"30"];
    _reloading = YES;
}

-(void)doneLoadingTableViewData {
    _reloading = NO;
    [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.theTableView];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view {
    [self reloadTableViewDataSource];
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:0.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view {
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view {
    return [NSDate date];
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if ([self.arr_data count]) {
        UIImage *currentImage = [self captureScreen];
        [self pushingViewController:currentImage];
        
        EventDetailViewController *event = [[EventDetailViewController alloc]initWithNibName:@"EventDetailViewController" bundle:nil];
        event.dict_data = [self.arr_data objectAtIndex:indexPath.row];
        
        [self.navigationController pushViewController:event animated:NO]; 
        [event release];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

	UITableViewCell *cell;
	NSString *eventInfoCell = @"eventInfoCell";
	cell = [tableView dequeueReusableCellWithIdentifier:eventInfoCell];
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:eventInfoCell] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
		
		UIImageView *event_in_knit_img = [[UIImageView alloc]initWithFrame:CGRectMake(13,23,13,13)];
        event_in_knit_img.tag = 3;
        event_in_knit_img.backgroundColor = [UIColor clearColor];
        [cell.contentView addSubview:event_in_knit_img];
        [event_in_knit_img release];

        
        UILabel *lbl_event_title = [[UILabel alloc]initWithFrame:CGRectMake(35, 10, 210, 15)];
		lbl_event_title.tag = 1;
		lbl_event_title.backgroundColor = [UIColor clearColor];
		lbl_event_title.numberOfLines = 1;
        lbl_event_title.lineBreakMode = UILineBreakModeTailTruncation;
		lbl_event_title.textColor = [UIColor darkGrayColor];
		lbl_event_title.textAlignment = UITextAlignmentLeft;
		lbl_event_title.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14];
		[cell.contentView addSubview:lbl_event_title];
		[lbl_event_title release];

        UILabel *lbl_event_detail = [[UILabel alloc]initWithFrame:CGRectMake(35, 25, 210, 15)];
		lbl_event_detail.tag = 4;
		lbl_event_detail.backgroundColor = [UIColor clearColor];
		lbl_event_detail.numberOfLines = 1;
        lbl_event_detail.lineBreakMode = UILineBreakModeTailTruncation;
		lbl_event_detail.textColor = [UIColor grayColor];
		lbl_event_detail.textAlignment = UITextAlignmentLeft;
		lbl_event_detail.font = [UIFont fontWithName:@"helvetica Neue" size:12];
		[cell.contentView addSubview:lbl_event_detail];
		[lbl_event_detail release];

		UILabel *lbl_dateTime = [[UILabel alloc] initWithFrame:CGRectMake(35, 40, 210, 10)];
		lbl_dateTime.tag = 2;
		lbl_dateTime.text = @"";
		lbl_dateTime.backgroundColor = [UIColor clearColor];
		lbl_dateTime.textColor = [UIColor grayColor];
		lbl_dateTime.numberOfLines = 1;
		lbl_dateTime.font = [UIFont fontWithName:@"helvetica Neue" size:10];
        lbl_dateTime.textAlignment = UITextAlignmentLeft;
		[cell.contentView addSubview:lbl_dateTime];
		[lbl_dateTime release];
	}
	
	UILabel *lbl_event_title = (UILabel *)[cell.contentView viewWithTag:1];
	UILabel *lbl_event_detail = (UILabel *)[cell.contentView viewWithTag:4];
	UILabel *lbl_dateTime =  (UILabel *)[cell.contentView viewWithTag:2];
    UIImageView *event_in_knit_img = (UIImageView *)[cell.contentView viewWithTag:3];
	
	if ([self.arr_data count] == 0) {
		cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:13];
		cell.textLabel.textColor = [UIColor darkGrayColor];
		cell.textLabel.textAlignment = UITextAlignmentLeft;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
		cell.textLabel.text = @"No events are listed for your area. Know of an event? Share with other parents.";
		lbl_event_title.text = @"";
		lbl_dateTime.text = @"";
        [cell.textLabel sizeToFit];
	}else {
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.text = @"";
        
        NSMutableDictionary *dict = [self.arr_data objectAtIndex:indexPath.row];
        
        lbl_event_title.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"txtEventTitle"]];
        lbl_event_detail.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"txtEventDetail"]];
        lbl_dateTime.text = @"posted: ";
        lbl_dateTime.text = [lbl_dateTime.text stringByAppendingString:[self dateFormatter:indexPath]];

		
		cell.tag = indexPath.row+1;
		if ([self.arr_data count] == 0) {
			self.navigationController.navigationItem.rightBarButtonItem.enabled = NO;
		}

        if ([[dict objectForKey:@"txtEventSubmitterInKnitFlag"] isEqualToString:@"1"]) {
            event_in_knit_img.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_InKnit")];
        }

	}
	
	return cell;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 60;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
		int RET = 1;
	if ([self.arr_data count]) {
		RET = [self.arr_data count];
	}
	
	return RET;
}

#pragma mark -
#pragma mark API Response

- (void) getEventsResponse : (NSData *)data {
	
	NSDictionary *response = [[data stringValue] JSONValue];
//	[DELEGATE removeLoadingView:self.vi_main];
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
        [self.arr_data removeAllObjects];
		self.arr_data = [[response objectForKey:@"response"] objectForKey:@"Events"];
	}
	
	[self.theTableView reloadData];
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

#pragma mark -
#pragma mark UITableView Components
- (NSString *) dateFormatter:(NSIndexPath *) indexPath{

	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SZ"];
	
	NSUInteger desiredComponents = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit 
	| NSMinuteCalendarUnit | NSSecondCalendarUnit;
	
	
//	NSArray *arr = [[[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtSubmissionTimestamp"] componentsSeparatedByString:@"."];
//	NSString *strTimeStamp = [arr objectAtIndex:0];
//	NSDate *date =[formatter dateFromString:strTimeStamp];
	NSDate *date =[formatter dateFromString:[[self.arr_data objectAtIndex:indexPath.row] objectForKey:@"txtSubmissionTimestamp"]];
	NSDateComponents *elapsedTimeUnits = [[NSCalendar currentCalendar] components: desiredComponents
																		 fromDate: date
																		   toDate: [NSDate date]
																		  options:0];
	// format to be used to generate string to display
	NSString *scannedFormat = @"%d %@ ago";
	NSInteger number = 0;
	NSString *unit;
	
	if ([elapsedTimeUnits year] > 0) {
		number = [elapsedTimeUnits year];
		unit = [NSString stringWithFormat:@"year"];
	}
	else if ([elapsedTimeUnits month] > 0) {
		number = [elapsedTimeUnits month];
		unit = [NSString stringWithFormat:@"month"];
	}
	else if ([elapsedTimeUnits week] > 0) {
		number = [elapsedTimeUnits week];
		unit = [NSString stringWithFormat:@"week"];
	}
	else if ([elapsedTimeUnits day] > 0) {
		number = [elapsedTimeUnits day];
		unit = [NSString stringWithFormat:@"day"];
	}
	else if ([elapsedTimeUnits hour] > 0) {
		number = [elapsedTimeUnits hour];
		unit = [NSString stringWithFormat:@"hour"];
	}
	else if ([elapsedTimeUnits minute] > 0) {
		number = [elapsedTimeUnits minute];
		unit = [NSString stringWithFormat:@"minute"];
	}
	else if ([elapsedTimeUnits second] > 0) {
		number = [elapsedTimeUnits second];
		unit = [NSString stringWithFormat:@"second"];
	}
	// check if unit number is greater then append s at the end
	if (number > 1) {
		unit = [NSString stringWithFormat:@"%@s", unit];
	}
	// resultant string required
	NSString *scannedString = [NSString stringWithFormat:scannedFormat, number, unit] ;
	
	[formatter release];
	return scannedString;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    _refreshHeaderView=nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	_refreshHeaderView = nil;
    [self.arr_data release];
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
    [super dealloc];
}
@end