//
//  PlayDateViewController.m
//  TykeKnit
//
//  Created by Abhinav Singh on 23/11/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "PlayDateViewController.h"
#import "ParentDetailViewController.h"
#import "PlaydateScheduleViewController.h"
#import "PlaceMark.h"
#import "Global.h"
#import "JSON.h"
#import "ValuesSelectionView.h"
#import "KidsListDetailViewController.h"
#import "PlaydateTabbar.h"
#import "LocationMannager.h"
#import "Messages.h"
#import "TableCellImageView.h"
#import "AddFriendsViewController.h"
#import "WannaHangViewController.h"


#define DEFAULT_SEARCH_RADIUS @"1000"
#define DEFAULT_RESULTS_COUNT @"20" 

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;

@implementation PlayDateViewController

@synthesize mapView, arr_mapParents, calloutAnnotation, selectedAnnotion,theTableView,dict_scheduleData,api_tyke,arr_listParents;
@synthesize btn_back,loc_currentResults,latestUserPositionUpdated,reloadView,theSearchBar,filter_tabBar,annotationViewShown,arr_searchParents;
@synthesize reloadButtonShown,reloadButtonTriggerOn,ListViewOn,rightSideView,Searching,filterIsOn,BullsEyeClicked,loadingRequest;

- (void) BringFrontSubViews {
//	[self.vi_main bringSubviewToFront:filter_tabBar];
	[super BringFrontSubViews];
}

- (void) animationDidStopLocal:(NSString*)animationID finished:(BOOL)finished context:(void *)context {
	
	if ([animationID isEqualToString:@"removeMapView"]) {
		[self.mapView setHidden:YES];
		animatingTransform = NO;
		if([arr_mapParents count] == 0){
			UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"TykeKnit"
													 message:@"There are no other TykeKnit users close to your location. Do you want to invite your friends to join you on TykeKnit?"
													 delegate:self
													 cancelButtonTitle:nil
													 otherButtonTitles:@"Add Now", @"Skip", nil];
			[alert show];
			[alert setTag:300];
			[alert release];
		}
	}else if ([animationID isEqualToString:@"removeTableView"]){
		[theTableView setHidden:YES];
		animatingTransform = NO;
	}else if ([animationID isEqualToString:@"decreaseYCord"]) {
		[self.reloadView removeFromSuperview];
	}else if([animationID isEqualToString:@"SearchViewAnimation"]) {
		//		[[[DELEGATE window] viewWithTag:102] removeFromSuperview];
	}
}

- (void) viewWillDisappear:(BOOL)animated {
	
	if (![[[DELEGATE dict_settings] objectForKey:@"currnetLocAsDefault"] intValue]) {
		[DELEGATE switchLocationManagerOn:NO];
	}
	[super viewWillDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
	
	if ([[[DELEGATE window] subviews] containsObject:[DELEGATE nav_wannaHangBar].view]) {
		[[DELEGATE nav_wannaHangBar].view removeFromSuperview];
	}
	
	if (![[[DELEGATE dict_settings] objectForKey:@"currnetLocAsDefault"] intValue]) {
		[DELEGATE switchLocationManagerOn:YES];
	}
	
	
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_playDateSearch aboveSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_playDate_send belowSubview:[DELEGATE vi_sideView].img_back];
	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_wannaHang belowSubview:[DELEGATE vi_sideView].img_back];
//	[[DELEGATE vi_sideView] insertSubview:[DELEGATE vi_sideView].btn_settings3 belowSubview:[DELEGATE vi_sideView].img_back];
	
	
	if ([[self.dict_scheduleData allKeys] count] > 3) {
		self.btn_back.hidden = NO;
	}else {
		self.btn_back.hidden = YES;
	}
	[super viewWillAppear:animated];
}

- (void) showListView : (id) sender {
	
	if ([[DELEGATE nav_wannaHangBar].view superview] || animatingTransform) {
		return;
	}
	
	
	if (!self.theTableView) {
//		self.theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 31, 280, 327) style:UITableViewStylePlain];
		self.theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 31, 280, 380) style:UITableViewStylePlain];
		self.theTableView.delegate = self;
		self.theTableView.dataSource = self;
		self.theTableView.hidden = YES;
		[self.vi_main addSubview:self.theTableView];
	}
	
	UIButton *leftNavButton = (UIButton *)sender;

	
	if (!ListViewOn) {		//Map To List
		
		ListViewOn = YES;
		animatingTransform = YES;
		
		theTableView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001f, 0.001f);
		self.theTableView.hidden = NO;
		
		if (![[self.vi_main subviews] containsObject:self.theSearchBar]) {
			[self.theSearchBar setFrame:CGRectMake(0, 0, 280, 40)];
			[self.vi_main insertSubview:self.theSearchBar aboveSubview:self.mapView];
		}
//		[self.theSearchBar becomeFirstResponder];
		[self.theSearchBar setHidden:NO];
				
		[UIView beginAnimations:@"removeMapView" context:nil];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[theTableView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0f, 1.0f)];
//		[self.theTableView setFrame:CGRectMake(0, 40, 280, 327)];
		[self.theTableView setFrame:CGRectMake(0, 40, 280, 380)];
		[UIView setAnimationDidStopSelector:@selector(animationDidStopLocal:finished:context:)];
		[UIView commitAnimations];
		[self.theTableView reloadData];
		
		[self removeReloadButton];
		
		[leftNavButton setTitle:@"Map" forState:UIControlStateNormal];
	}else {		//List To Map
		
		ListViewOn = NO;
		animatingTransform = YES;
		self.mapView.hidden = NO;
		
//		[self.vi_main addSubview:self.mapView];
		[self.theSearchBar setHidden:YES];
		[self.theSearchBar resignFirstResponder];
		
		[UIView beginAnimations:@"removeTableView" context:nil];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.5];
		[theTableView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.001f, 0.001f)];
		[UIView setAnimationDidStopSelector:@selector(animationDidStopLocal:finished:context:)];
		[UIView commitAnimations];
		[leftNavButton setTitle:@"List" forState:UIControlStateNormal];
		
		[self.vi_main bringSubviewToFront:theTableView];
		
	}
	[self BringFrontSubViews];
}

- (void) reloadForChangedZipCode : (NSNotification*) notify{
	
	self.loc_currentResults = [DELEGATE getCurrentLocation];
	if (self.loc_currentResults) {
		self.BullsEyeClicked = YES;
		NSString *latitude = [NSString stringWithFormat:@"%f",self.loc_currentResults.coordinate.latitude];
		NSString *longitude = [NSString stringWithFormat:@"%f",self.loc_currentResults.coordinate.longitude];
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke markUserPosition:latitude Longitude:longitude];
	}
}

- (void) viewDidLoad {

	self.navigationItem.titleView = [DELEGATE getTykeTitleViewWithTitle:@"Search"];
	
	//shadow for Navigationbar
	CGColorRef darkColor = [[UIColor blackColor] colorWithAlphaComponent:.5f].CGColor;
	CGColorRef lightColor = [UIColor clearColor].CGColor;
	
	CAGradientLayer *newShadow = [[[CAGradientLayer alloc] init] autorelease];
	newShadow.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, self.navigationController.navigationBar.frame.size.width, 7);
	newShadow.colors = [NSArray arrayWithObjects:(id)darkColor, (id)lightColor, nil];
	[self.navigationController.navigationBar.layer addSublayer:newShadow];	
	
	self.reloadButtonShown = NO;
	self.loadingRequest = NO;
	self.ListViewOn = NO;
	self.Searching = NO;
	self.filterIsOn = NO;
	self.BullsEyeClicked =NO;
	
	self.arr_mapParents = [[NSMutableArray alloc] init];
	self.arr_listParents = [[NSMutableArray alloc] init];
	self.arr_searchParents = [[NSMutableArray alloc] init];
	self.api_tyke = [[TykeKnitApi alloc] init];
	[api_tyke setDelegate:self];
	
	if (!self.dict_scheduleData) {
		self.dict_scheduleData = [[NSMutableDictionary alloc] init];
	}
	
	self.rightSideView = [DELEGATE vi_sideView];
	self.rightSideView.delegate = self;
	[self.theTableView setBackgroundColor:[UIColor colorWithRed:0.9294 green:0.9490 blue:0.9568 alpha:1.0]];
	
	UIButton *btn_list = [DELEGATE getDefaultBarButtonWithTitle:@"List"];
	btn_list.tag = 101;
	[btn_list addTarget:self action:@selector(showListView:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:btn_list] autorelease];
	[self.navigationItem.rightBarButtonItem setEnabled:YES];
	
	UIButton *btn_BullsEye = [UIButton buttonWithType:UIButtonTypeCustom];
	btn_BullsEye.frame = CGRectMake(0, 0, 48, 31);
	[btn_BullsEye addTarget:self action:@selector(bullsEye:) forControlEvents:UIControlEventTouchUpInside];
	[btn_BullsEye setImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_bullsEye")] forState:UIControlStateNormal];
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]initWithCustomView:btn_BullsEye] autorelease];
	
//	filter_tabBar = [[PlaydateTabbar alloc] initWithFrame:CGRectMake(0, 363, 280, 40)];
//	filter_tabBar.delegate = self;
//	[self.vi_main addSubview:filter_tabBar];
	
	self.latestUserPositionUpdated = nil;
	[self performSelectorOnMainThread:@selector(initMapView) withObject:nil waitUntilDone:YES];
	
	self.theSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 280, 40)];
	self.theSearchBar.placeholder = @"Parent or Tyke Name  ";
	self.theSearchBar.tag = 101;
	self.theSearchBar.hidden = YES;
	
	self.theSearchBar.delegate = self;
	[self.vi_main insertSubview:self.theSearchBar aboveSubview:self.mapView];
	
	self.loc_currentResults = [DELEGATE getCurrentLocation];
	if (self.loc_currentResults) {
		NSString *latitude = [NSString stringWithFormat:@"%f",self.loc_currentResults.coordinate.latitude];
		NSString *longitude = [NSString stringWithFormat:@"%f",self.loc_currentResults.coordinate.longitude];
		[DELEGATE addLoadingView:self.vi_main];
		[api_tyke markUserPosition:latitude Longitude:longitude];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadForChangedZipCode:) name:ZIP_CODE_CHANGED object:nil];
	[super viewDidLoad];
}

- (void) valuesSelectionCompleted : (NSMutableArray*)arrselectedValues TypeOf:(NSString*)str_typeOf{
	
	if (arrselectedValues) {
		if ([str_typeOf isEqualToString:@"Gender"]) {
			[arrselectedValues writeToFile:[DOC_DIR stringByAppendingPathComponent:@"DefaultGenderArray.plist"] atomically:NO];
		}
		else if ([str_typeOf isEqualToString:@"Degree"]){
			
			[arrselectedValues writeToFile:[DOC_DIR stringByAppendingPathComponent:@"DefaultDegreeArray.plist"] atomically:NO];
		}
		else if ([str_typeOf isEqualToString:@"Age"]){
			
			[arrselectedValues writeToFile:[DOC_DIR stringByAppendingPathComponent:@"DefaultAgeArray.plist"] atomically:NO];
		}
	}

	NSString *latitude = [NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.latitude];
	NSString *longitude = [NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.longitude];

    self.filterIsOn = YES;
    [DELEGATE addLoadingView:self.vi_main];
    [api_tyke getMap:latitude 
           Longitude:longitude
              Radius:[NSString stringWithFormat:@"%f",[self getMapRadius]*3] 
                searchString:nil 
                count:nil start:nil 
     ];

	vi_valuesSelection = nil;
//	[filter_tabBar selectionCompleted:str_typeOf];
}

- (void) btn_backClicked : (id) sender {
	if (self.dict_scheduleData) {
		UIImage *currentImage = [self captureScreen];
		[self pushingViewController:currentImage];
		PlaydateScheduleViewController *playdateScheduleViewController = [[PlaydateScheduleViewController alloc]initWithNibName:@"PlaydateScheduleViewController" bundle:nil];
		playdateScheduleViewController.prevContImage = currentImage;
		playdateScheduleViewController.dict_scheduleData = self.dict_scheduleData;
		[self.navigationController pushViewController:playdateScheduleViewController animated:NO];
		[playdateScheduleViewController release];
	}
}

- (void) initMapView {
	
//	self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 280, 363)];
	self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 280, 415)];
	self.mapView.delegate = self;
	self.mapView.mapType = MKMapTypeStandard;
	self.mapView.region = MKCoordinateRegionMakeWithDistance(self.loc_currentResults.coordinate, 32186.88f, 32186.88f);//region for 20 miles area
	[self.vi_main addSubview:self.mapView];
	[self.mapView setShowsUserLocation:NO];
	[self.mapView setHidden:NO];
	[self.mapView release];
	
	//	self.arr_mapParents = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"dummyMapResponse" ofType:@"plist"]];
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 301) {
		[self.theSearchBar becomeFirstResponder];
	}else if (alertView.tag == 302) {
		if (buttonIndex == 1) {
			[DELEGATE addLoadingView:self.vi_main];
			[api_tyke getMap:[NSString stringWithFormat:@"%f", self.loc_currentResults.coordinate.latitude] 
				   Longitude:[NSString stringWithFormat:@"%f", self.loc_currentResults.coordinate.longitude] 
					  Radius:[NSString stringWithFormat:@"%f",[self getMapRadius]*3] 
				searchString:nil 
					   count:nil 
					   start:nil 
			 ];
		}
	}else if (alertView.tag == 300) {

		UIImage *currentImage = [self captureScreen];

		UIButton *btn = (UIButton *)self.navigationItem.rightBarButtonItem.customView;
		[self showListView:btn];
		
		if(buttonIndex == 0){
			[self pushingViewController:currentImage];
			AddFriendsViewController *frdsVC = [[AddFriendsViewController alloc] initWithNibName:@"AddFriendsViewController" bundle:nil];
			frdsVC.prevContImage = currentImage;
			[self.navigationController pushViewController:frdsVC animated:NO];
			[frdsVC release];
		}
	}
}

#pragma mark -
#pragma mark PlaydateTabbar Delegate

- (void) buttonSelectedOfName : (NSString*) name {
	
	BOOL createNew = YES;
	if (vi_valuesSelection) {
		
		if ([vi_valuesSelection.str_typeOfSelection isEqualToString:name]) {
			createNew = NO;
//			[self.filter_tabBar selectionCompleted:name];
		}
		[vi_valuesSelection removeFromSuperview];
		vi_valuesSelection = nil;
	}
	if (createNew) {
		if ([name isEqualToString:@"Gender"]) {
			NSMutableArray *arrGender = [NSMutableArray arrayWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"DefaultGenderArray.plist"]];
			if (!arrGender) {
				arrGender = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultGenderArray" ofType:@"plist"]];
			}
			
			vi_valuesSelection = [[ValuesSelectionView alloc] initWithFrame:CGRectMake(10, 337, 260 , 30) 
																	 Values:arrGender Style:SelectionStyleSingle];
			[vi_valuesSelection showPointAtLocation:CGPointMake(25, 20)];
			vi_valuesSelection.str_typeOfSelection = @"Gender";
		}else if([name isEqualToString:@"Degree"]){
			
			NSMutableArray *arrDegree = [NSMutableArray arrayWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"DefaultDegreeArray.plist"]];
			if (!arrDegree) {
				arrDegree = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultDegreeArray" ofType:@"plist"]];
			}
			vi_valuesSelection = [[ValuesSelectionView alloc] initWithFrame:CGRectMake(10, 337, 260 , 30) 
																	 Values:arrDegree Style:SelectionStyleSingle];
			
			[vi_valuesSelection showPointAtLocation:CGPointMake(115, 20)];
			vi_valuesSelection.str_typeOfSelection = @"Degree";
		}else if([name isEqualToString:@"Age"]) {
			
			NSMutableArray *arrAge = [NSMutableArray arrayWithContentsOfFile:[DOC_DIR stringByAppendingPathComponent:@"DefaultAgeArray.plist"]];
			if (!arrAge) {
				arrAge = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DefaultAgeArray" ofType:@"plist"]];
			}
			vi_valuesSelection = [[ValuesSelectionView alloc] initWithFrame:CGRectMake(10, 337, 260 , 30) 
																	 Values:arrAge Style:SelectionStyleSingle];
			
			[vi_valuesSelection showPointAtLocation:CGPointMake(195, 20)];
			vi_valuesSelection.str_typeOfSelection = @"Age";
		}
		
		vi_valuesSelection.targetController = self;
		
		[self.vi_main addSubview:vi_valuesSelection];
		[vi_valuesSelection release];
	}
}

#pragma mark -
#pragma mark SearchBarDelgate

- (void) search_CancelClicked {
	
	[UIView beginAnimations:@"SearchViewAnimation" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStopLocal:finished:context:)];
	[[[DELEGATE window] viewWithTag:104] removeFromSuperview];
	[[[DELEGATE window] viewWithTag:100] removeFromSuperview];
	[[[DELEGATE window] viewWithTag:102] removeFromSuperview];
	[UIView commitAnimations];
	[self.theSearchBar setFrame:CGRectMake(0, 0, 280, 40)];	
	[self.vi_main insertSubview:self.theSearchBar aboveSubview:self.mapView];
	[self.theSearchBar resignFirstResponder];
	[[[DELEGATE window] viewWithTag:102] resignFirstResponder];
	self.Searching = NO;
	[self.theTableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSString *searchText = self.theSearchBar.text;
	if ([searchText length]) {
		
		self.Searching = YES;
		NSString *latitude = [NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.latitude];
		NSString *longitude = [NSString stringWithFormat:@"%f",self.mapView.centerCoordinate.longitude];
//		CGRect *rect =  self.mapView.visibleMapRect;
		[DELEGATE addLoadingView:self.vi_main];
			[api_tyke getMap:latitude
				   Longitude:longitude
					  Radius:[NSString stringWithFormat:@"%f",[self getMapRadius]*3]
				searchString:searchText
					   count:nil start:nil 
			 ];
	}
	
	[[[DELEGATE window] viewWithTag:100] removeFromSuperview];
	[UIView beginAnimations:@"SearchViewAnimation" context:nil];
	[UIView setAnimationDuration:0.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStopLocal:finished:context:)];
	[[[DELEGATE window] viewWithTag:104] removeFromSuperview];
	[[[DELEGATE window] viewWithTag:100] removeFromSuperview];
	[[[DELEGATE window] viewWithTag:102] removeFromSuperview];
	[UIView commitAnimations];
	[self.theSearchBar setFrame:CGRectMake(0, 0, 280, 40)];	
	[self.vi_main insertSubview:self.theSearchBar aboveSubview:self.mapView];
	[self.theSearchBar resignFirstResponder];
	[[[DELEGATE window] viewWithTag:102] resignFirstResponder];
	
	[self.theSearchBar resignFirstResponder];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	
	if (searchBar.tag == 101 && ![[DELEGATE window] viewWithTag:104]) {
		[self.theSearchBar setFrame:CGRectMake(0, 64, 320, 40)];
		[[DELEGATE window] addSubview:self.theSearchBar];
		self.theSearchBar.text = @"";

		UIView *vi_back = [[UIView alloc]initWithFrame:CGRectMake(0, 400, 320, 0)];
		[vi_back setBackgroundColor:[UIColor blackColor]];
		vi_back.tag = 100;
		[vi_back setAlpha:0.6];
		[UIView beginAnimations:@"forbackview" context:nil];
		[UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
		[vi_back setFrame:CGRectMake(0, 104, 320, 200)];
		[[DELEGATE window] addSubview:vi_back];
		[UIView commitAnimations];
		[vi_back release];
		
		UINavigationItem *nav_item = [[UINavigationItem alloc]init];
		[nav_item setTitleView:[DELEGATE getTykeTitleViewWithTitle:@"Search"]];
		
		UIButton *btn_cancel = [DELEGATE getDefaultBarButtonWithTitle:@"Cancel"];
		[btn_cancel addTarget:self action:@selector(search_CancelClicked) forControlEvents:UIControlEventTouchUpInside];
		nav_item.rightBarButtonItem =[[[UIBarButtonItem alloc] initWithCustomView:btn_cancel] autorelease];
		
		UINavigationBar *nav_searchBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 20, 320, 44)];
		nav_searchBar.tag = 104;
		[nav_searchBar setTintColor:[UIColor colorWithRed:0.623 green:0.850 blue:0.996 alpha:1]];
		[nav_searchBar setItems:[NSArray arrayWithObject:nav_item]];
		[nav_item release];
		
		[[DELEGATE window] addSubview:nav_searchBar];
		[nav_searchBar release];
		
	}
}

#pragma mark -
#pragma mark RightSideViewDelegate

- (void) buttonClickedNamed : (NSString*) name {
	
	if ([name isEqualToString:@"Search"]) {
		
		for (UIViewController *viewCont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
		if ([[[self.navigationController viewControllers] objectAtIndex:0] isKindOfClass:[[self.navigationController visibleViewController] class]] ) {
			[self viewWillAppear:NO];
		}
		[self.navigationController popToRootViewControllerAnimated:NO];
		
	}else if ([name isEqualToString:@"Send"]) {
		for (UIViewController *viewCont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
		PlaydateScheduleViewController *playdateScheduleViewController = [[PlaydateScheduleViewController alloc]initWithNibName:@"PlaydateScheduleViewController" bundle:nil];
		playdateScheduleViewController.dict_scheduleData = self.dict_scheduleData;
		[self.navigationController pushViewController:playdateScheduleViewController animated:NO];
		[playdateScheduleViewController release];
	}else if ([name isEqualToString:@"WannaHang"]) {
		for (UIViewController *viewCont in [self.navigationController viewControllers]) {
			[self.navigationController popViewControllerAnimated:NO];
		}
		WannaHangViewController *wannaHangViewController = [[WannaHangViewController alloc]initWithNibName:@"WannaHangViewController" bundle:nil];
		[self.navigationController pushViewController:wannaHangViewController animated:NO];
		[wannaHangViewController release];
	}
}
- (void) hideBackButton {
	NSLog(@"%s", __PRETTY_FUNCTION__);
	[self.navigationItem setHidesBackButton:YES animated:NO];
}
/*
- (BOOL) isWannaHangHighlighted {
	
	BOOL RET = NO;
	if([[DELEGATE vi_wannaHang] superview]) {
		RET = YES;
	}
	return RET;
}
*/
#pragma mark -
#pragma mark MapView Methods

- (CGFloat) getMapRadius {


	MKMapRect mRect = self.mapView.visibleMapRect;
	MKMapPoint neMapPoint = MKMapPointMake(mRect.origin.x + mRect.size.width, mRect.origin.y);
	MKMapPoint swMapPoint = MKMapPointMake(mRect.origin.x, mRect.origin.y + mRect.size.height);
	CLLocationCoordinate2D neCoord = MKCoordinateForMapPoint(neMapPoint);
	CLLocationCoordinate2D swCoord = MKCoordinateForMapPoint(swMapPoint);	

	CLLocation *loc_NorthEast = [[CLLocation alloc] initWithLatitude:neCoord.latitude longitude:neCoord.longitude];
	CLLocation *loc_SouthWest = [[CLLocation alloc] initWithLatitude:swCoord.latitude longitude:swCoord.longitude];
	
		CLLocationDistance distance = [loc_NorthEast distanceFromLocation:loc_SouthWest];
	CLLocationDistance distanceInMiles = distance *0.000621371192;
	return distanceInMiles;

}

- (void) bullsEye:(id) sender {
	
	
	self.BullsEyeClicked = YES;
	self.reloadButtonTriggerOn = NO;
	self.loc_currentResults = [DELEGATE getCurrentLocation];
	if (self.loc_currentResults) {
		if (!loadingRequest) {
			self.Searching = NO;
			self.loadingRequest = YES;
			[DELEGATE addLoadingView:self.vi_main];
			[self getMapRadius];
			[api_tyke getMap:[NSString stringWithFormat:@"%f", self.loc_currentResults.coordinate.latitude] 
				   Longitude:[NSString stringWithFormat:@"%f", self.loc_currentResults.coordinate.longitude] 
					  Radius:[NSString stringWithFormat:@"%f",[self getMapRadius]*3] 
				searchString:nil 
					   count:nil 
					   start:nil 
			];
		[self removeReloadButton];					
		}
	}
}

- (void) setZoomLevelOfMap {
	
	MKCoordinateRegion region;
	if (!self.reloadButtonTriggerOn) {
		CLLocationDegrees maxLat = -90;
		CLLocationDegrees maxLon = -180;
		CLLocationDegrees minLat = 90;
		CLLocationDegrees minLon = 180;
		
		for(int idx = 0; idx < [self.arr_mapParents count]; idx++) {
			
			NSDictionary *dictData = [self.arr_mapParents objectAtIndex:idx];
			
			float latitude = [[dictData objectForKey:@"txtCoordinatesLat"] doubleValue];
			float longitude = [[dictData objectForKey:@"txtCoordinatesLon"] doubleValue];
			
			CLLocation* currentLocation = [[[CLLocation alloc] 
											initWithLatitude:latitude
											longitude:longitude] autorelease];
			
			if (currentLocation.coordinate.latitude > maxLat)
				maxLat = currentLocation.coordinate.latitude;
			if (currentLocation.coordinate.latitude < minLat)
				minLat = currentLocation.coordinate.latitude;
			if (currentLocation.coordinate.longitude > maxLon)
				maxLon = currentLocation.coordinate.longitude;
			if (currentLocation.coordinate.longitude < minLon)
				minLon = currentLocation.coordinate.longitude;
		}
		
		region.center.latitude = (maxLat + minLat) / 2;
		region.center.longitude = (maxLon + minLon) / 2;
		region.center.latitude = self.loc_currentResults.coordinate.latitude;
		region.center.longitude = self.loc_currentResults.coordinate.longitude;
		
		self.reloadButtonTriggerOn = NO;
	}	 else {
		
		CLLocation *userLcoation = [[[CLLocation alloc] initWithLatitude:self.mapView.centerCoordinate.latitude 
															   longitude:self.mapView.centerCoordinate.longitude] autorelease];
		
		CLLocationDegrees maxLatDifference = 0;
		CLLocationDegrees minLatDiffrence = 0;
		CLLocationDegrees maxLongDifference = 0;
		CLLocationDegrees minLongDiffrence = 0;
		
		for(int idx = 0; idx < [self.arr_mapParents count]; idx++) {
			NSDictionary *dictData = [self.arr_mapParents objectAtIndex:idx];
			
			float latitude = [[dictData objectForKey:@"txtCoordinatesLat"] doubleValue];
			float longitude = [[dictData objectForKey:@"txtCoordinatesLon"] doubleValue];
			
			CLLocation* currentLocation;			
			currentLocation = [[[CLLocation alloc] 
								initWithLatitude:latitude
								longitude:longitude] autorelease];
			
			CLLocationDegrees latDifference  = userLcoation.coordinate.latitude - currentLocation.coordinate.latitude;
			CLLocationDegrees longDifference  = userLcoation.coordinate.longitude - currentLocation.coordinate.longitude;
			
			minLatDiffrence = currentLocation.coordinate.latitude;
			minLongDiffrence = currentLocation.coordinate.longitude;
			
			if (latDifference > maxLatDifference) 
				maxLatDifference = latDifference;
			if (latDifference < minLatDiffrence) 
				minLatDiffrence = latDifference;
			if (longDifference  > maxLongDifference) 
				maxLongDifference = longDifference;
			if (longDifference < minLongDiffrence) 
				minLongDiffrence = longDifference;
		}
		
		region.center.latitude = ((maxLatDifference + minLatDiffrence)/2) + self.mapView.centerCoordinate.latitude;
		region.center.longitude =((maxLongDifference+minLongDiffrence)/2) + self.mapView.centerCoordinate.longitude;
		region.center.latitude = self.mapView.centerCoordinate.latitude;// + minLatDiffrence;
		region.center.longitude = self.mapView.centerCoordinate.longitude;// + minLongDiffrence;
//		region.center.latitude = self.loc_currentResults.coordinate.latitude;
//		region.center.longitude = self.loc_currentResults.coordinate.longitude;
		self.reloadButtonTriggerOn = NO;
	}
	if (region.center.latitude == 0.0f && region.center.longitude == 0.0f) {
		region.center.latitude = self.loc_currentResults.coordinate.latitude;
		region.center.longitude = self.loc_currentResults.coordinate.longitude;
	}
	region = MKCoordinateRegionMakeWithDistance(region.center, 64373.76f, 64373.76f);//region for 20 miles area
	//	region = MKCoordinateRegionMakeWithDistance(region.center, 16093.44f, 16093.44f);
	if (region.span.latitudeDelta > 0 && region.span.longitudeDelta) {
		[self.mapView setRegion:region animated:YES];		
	}
}

- (void) reloadMapData {
	
	if (!loadingRequest) {
		
		self.loadingRequest = YES;
		
		[DELEGATE addLoadingView:self.vi_main];
		self.Searching = NO;
		[api_tyke getMap:[NSString stringWithFormat:@"%f", self.mapView.region.center.latitude] 
			   Longitude:[NSString stringWithFormat:@"%f", self.mapView.region.center.longitude] 
				  Radius:[NSString stringWithFormat:@"%f",[self getMapRadius]*3]
			searchString:nil 
				   count:nil 
				   start:nil 
		 ];
		[self removeReloadButton];
	}
}

- (void) reloadBUttonClicked : (id) sender {
	
	self.reloadButtonTriggerOn = YES;
	[self reloadMapData];
	[self removeReloadButton];
}

- (void) removeReloadButton {
	
	[UIView beginAnimations:@"decreaseAlpha" context:NULL];
	[UIView setAnimationDuration:Trans_Duration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStopLocal:finished:context:)];
	[self.reloadView setAlpha:0.0f];
	[UIView commitAnimations];
	
	[UIView beginAnimations:@"decreaseYCord" context:NULL];
	[UIView setAnimationDuration:Trans_Duration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStopLocal:finished:context:)];
	[self.reloadView setFrame:CGRectMake(0, 480, 280, 50)];
	[UIView commitAnimations];
	
}

- (void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	if (!loadingRequest) {
		if (!self.filterIsOn) {
			[self showReloadButton];
		}else {
			self.filterIsOn = NO;
		}
	}
}

- (void) showReloadButton {
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(removeReloadButton) object:nil];
	[self performSelector:@selector(removeReloadButton) withObject:nil afterDelay:3];
	
	if (![self.reloadView superview] && !ListViewOn) {
		self.reloadView.frame = CGRectMake(0, 480, 280, 50);
		[self.view addSubview:self.reloadView];
		self.reloadView.alpha = 0.0f;
		[UIView beginAnimations:@"increaseAlpha" context:NULL];
		[UIView setAnimationDuration:Trans_Duration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[self.reloadView setAlpha:0.8];
		[UIView commitAnimations];
		
		[UIView beginAnimations:@"increaseYCord" context:NULL];
		[UIView setAnimationDuration:Trans_Duration];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
//		[self.reloadView setFrame:CGRectMake(0, 318, 280, 50)];
		[self.reloadView setFrame:CGRectMake(0, 370, 280, 50)];
		[UIView commitAnimations];
	}
}

- (void) mapView:(MKMapView *)mapView1 didSelectAnnotationView:(MKAnnotationView *)view1 {
	
	if ([view1.annotation isKindOfClass:[BasicMapAnnotation class]]) {
		if ([(BasicMapAnnotation *)view1.annotation dict_data]) {
			if (self.calloutAnnotation == nil) {
				self.calloutAnnotation = [[CalloutMapAnnotation alloc] initWithDataDictionary:[(BasicMapAnnotation*)view1.annotation dict_data]];
			} else {
				if ([[self.mapView annotations] containsObject:self.calloutAnnotation]) {
					annotationViewShown = YES;
					[self.mapView removeAnnotation:self.calloutAnnotation];
				}
				self.calloutAnnotation.dict_data = [(BasicMapAnnotation*)view1.annotation dict_data];
			}
		}else {
			if (self.calloutAnnotation == nil) {
				self.calloutAnnotation = [[CalloutMapAnnotation alloc]init];
			} else {
				if ([[self.mapView annotations] containsObject:self.calloutAnnotation]) {
					annotationViewShown = YES;
					[self.mapView removeAnnotation:self.calloutAnnotation];
				}
			}

			self.calloutAnnotation.userName = [[NSString stringWithFormat:@"%@ %@",[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"fname"],[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"lname"]] mutableCopy];
		}
		[self.mapView addAnnotation:self.calloutAnnotation];
		self.selectedAnnotion = view1;
		
		//		view1.image = [UIImage imageWithContentsOfFile:[(BasicMapAnnotation*)view1.annotation getImagePath]];
	}
}

- (void) mapView:(MKMapView *)mapView1 didDeselectAnnotationView:(MKAnnotationView *)view1 {

	if (self.calloutAnnotation  && ![view1.annotation isKindOfClass:[CalloutMapAnnotationView class]]) {
		view1.image = [UIImage imageWithContentsOfFile:[(BasicMapAnnotation*)view1.annotation getImagePath]];
		if (!annotationViewShown) {
			[self.mapView removeAnnotation:self.calloutAnnotation];
		}else {
			annotationViewShown = NO;
		}
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView1 viewForAnnotation:(id <MKAnnotation>)annotation {
	
	if ([annotation isKindOfClass:[CalloutMapAnnotation class]]) {
		CalloutMapAnnotationView *calloutMapAnnotationView = (CalloutMapAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CalloutAnnotation"];
		if (!calloutMapAnnotationView) {
			calloutMapAnnotationView = [[[CalloutMapAnnotationView alloc] initWithAnnotation:annotation 
																			 reuseIdentifier:@"CalloutAnnotation"] autorelease];
			calloutMapAnnotationView.contentHeight = 60.0f;
			calloutMapAnnotationView.delegate = self;
		}
		
		calloutMapAnnotationView.parentAnnotationView = (MKAnnotationView*)self.selectedAnnotion;
		calloutMapAnnotationView.mapView = self.mapView;
		return calloutMapAnnotationView;
	}else if ([annotation isKindOfClass:[BasicMapAnnotation class]])  {
		
		MKAnnotationView *annotationView = [[[MKAnnotationView alloc] initWithAnnotation:annotation 
																		 reuseIdentifier:@"CustomAnnotation"] autorelease];
		annotationView.canShowCallout = NO;
		annotationView.image = [UIImage imageWithContentsOfFile:[(BasicMapAnnotation*)annotation getImagePath]];
		return annotationView;
	}
	
	return nil;
}

#pragma mark -
#pragma mark Tyke Api Delegate

- (void) MarkUserPosResponse : (NSData*)data {
	
	[DELEGATE removeLoadingView:self.vi_main];
	NSDictionary *response = [[data stringValue] JSONValue];
	
	if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"]) {
//		if (![self.arr_mapParents count]) {
				[DELEGATE addLoadingView:self.vi_main];
				
				[api_tyke getMap:[NSString stringWithFormat:@"%f", self.loc_currentResults.coordinate.latitude]
					   Longitude:[NSString stringWithFormat:@"%f", self.loc_currentResults.coordinate.longitude]
						  Radius:[NSString stringWithFormat:@"%f",[self getMapRadius]*3]
					searchString:nil 
						   count:nil start:nil 
				 ];
//		}
	}
}

- (void) getMapDetailsResponse : (NSData *) data {
	
	BOOL success  = NO;
	NSDictionary *response = [[data stringValue] JSONValue];
	[self.mapView removeAnnotations:[self.mapView annotations]];
	if ([response objectForKey:@"responseStatus"]) {
		if ([[response objectForKey:@"responseStatus"] isEqualToString:@"success"] && [[response objectForKey:@"response"] isKindOfClass:[NSDictionary class]]) {
			success = YES;
		}
	}
	
	if (!self.Searching) {
		[self.arr_mapParents removeAllObjects];
		[self.arr_listParents removeAllObjects];
	}else {
		[self.arr_searchParents removeAllObjects];
	}

	BOOL showAllParents = NO;
	float mapRadius = [self getMapRadius];
	if (mapRadius > 67.646079)	 {											//map radius for 20 miles region
		showAllParents = YES;
	}
	
	if (success) {
		
		if ([self.arr_mapParents count] || [self.arr_listParents count]) {
			self.reloadButtonShown = YES;
		}else {
			self.reloadButtonShown = NO;
		}
		
		
		if (![[[response objectForKey:@"response"] objectForKey:@"Parents"] count] || ([[[response objectForKey:@"response"] objectForKey:@"Parents"] count] == 1 && [[[[response objectForKey:@"response"] objectForKey:@"Parents"] objectAtIndex:0] count] == 0 )	){
			if (self.Searching) {
				UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
																   message:@"Unable to find any user with that name. Please try again."// MSG_ERROR_VALID_REGISTER4
																  delegate:self 
														 cancelButtonTitle:@"Ok" 
														 otherButtonTitles:nil];
				[objAlert show];
				[objAlert setTag:301];
				[objAlert release];
			}
		} else {

			for (NSDictionary *dictdata in [[response objectForKey:@"response"] objectForKey:@"Parents"]) {
				if ([[dictdata allKeys] count]) {
					
					float txtLat = [[dictdata objectForKey:@"txtCoordinatesLat"] doubleValue];
					float txtLong =[[dictdata objectForKey:@"txtCoordinatesLon"] doubleValue];
					
					if (![[dictdata objectForKey:@"txtUserTblPk"] isEqualToString:[[[DELEGATE dict_userInfo] objectForKey:@"response"] objectForKey:@"txtUserTblPk"]]) {
						
						CLLocation *loc = [[CLLocation alloc]initWithLatitude:txtLat longitude:txtLong];
						double distance = 0.0;
						if (self.reloadButtonTriggerOn) {
						CLLocation *loc_map = [[CLLocation alloc]initWithLatitude:self.mapView.centerCoordinate.latitude longitude:self.mapView.centerCoordinate.longitude];
						distance = [loc distanceFromLocation:loc_map];												//returns distance in meters
						[loc_map release];
						}else {
							distance = [loc distanceFromLocation:self.loc_currentResults];							//returns distance in meters
						}

						if (showAllParents) {
							[self.arr_mapParents addObject:dictdata];
						}else {
							float distanceInMiles = distance *0.00062;													//1 meter = 0.000621371192 miles
							if (distanceInMiles < 20.0f) {
								[self.arr_mapParents addObject:dictdata];
							}
						}

						if (self.Searching) {
							[self.arr_searchParents addObject:dictdata];
						}else {
							[self.arr_listParents addObject:dictdata];
						}
						
						[loc release];
					}
				}
			}
		}
		
		for (NSDictionary *dict in self.arr_mapParents) {
			
			if ([[dict objectForKey:@"DegreeCode"] intValue] >= 1 && [[dict objectForKey:@"DegreeCode"] intValue] <= 3) {
				BasicMapAnnotation *ano = [[[BasicMapAnnotation alloc] initWithDataDictionary:dict] autorelease];
				[self addAnnotationToMapView:ano];
			}
		}
	}
	else {
			UIAlertView *objAlert = [[UIAlertView alloc] initWithTitle:@"Sorry!" 
															   message:@"Unable to Connect Server.\n try again?."// MSG_ERROR_VALID_REGISTER4
															  delegate:self 
													 cancelButtonTitle:@"Cancel" 
													 otherButtonTitles:@"Try Again",nil];
			[objAlert show];
			[objAlert setTag:302];
			[objAlert release];
		
		if (!self.Searching) {
			[self.arr_mapParents removeAllObjects];
			[self.arr_listParents removeAllObjects];
		}
	}
	
	if ([self.arr_mapParents count]) {
	}
	
	if (self.loc_currentResults) {
		BasicMapAnnotation *ann = [[BasicMapAnnotation alloc] init];
		[ann setCoordinate:CLLocationCoordinate2DMake(self.loc_currentResults.coordinate.latitude, self.loc_currentResults.coordinate.longitude)];
		[self performSelectorOnMainThread:@selector(addAnnotationToMapView:) withObject:ann waitUntilDone:YES];
		[ann release];
	}
	
	if (!self.Searching) {
		if (!showAllParents || self.BullsEyeClicked) {
			self.BullsEyeClicked = NO;
			[self setZoomLevelOfMap];			
		}

	}
	
	[self.mapView setNeedsDisplay];
	[self.vi_main bringSubviewToFront:[self.vi_main viewWithTag:1212]];
	[self.theTableView reloadData];
	[DELEGATE removeLoadingView:self.vi_main];
	loadingRequest = NO;
}

- (void) noNetworkConnection {
	
	loadingRequest = NO;
	[DELEGATE removeLoadingView:self.vi_main];
}

- (void) failWithError : (NSError*) error {
	
	loadingRequest = NO;
	[DELEGATE removeLoadingView:self.vi_main];
}

- (void) requestCanceled {
	loadingRequest = NO;
	[DELEGATE removeLoadingView:self.vi_main];
}

#pragma mark -
#pragma mark TableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return 65;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	
	//	return [self.arr_mapParents count];
	if (self.Searching) {
		return [self.arr_searchParents count];
	}
	return [self.arr_listParents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	int rowIndex = [indexPath row];
	UITableViewCell *cell;
	cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	
	if (cell == nil){
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		self.theTableView.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
		
		UIImageView *img_Back = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 280, 65)];
		img_Back.backgroundColor = [UIColor clearColor];
		img_Back.tag = 11;
		[cell.contentView addSubview:img_Back];
		[img_Back release];
		
		TableCellImageView *img_KidPic = [[TableCellImageView alloc]initWithFrame:CGRectMake(15, 7, 50, 50)];
		img_KidPic.defaultImage = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
		img_KidPic.tag = 1;
		[cell.contentView addSubview:img_KidPic];
		[img_KidPic release];
		
		UIImageView *img_wannahang = [[UIImageView alloc]initWithFrame:CGRectMake(70, 7, 18, 18)];
		img_wannahang.tag = 2;
		[cell.contentView addSubview:img_wannahang];
		[img_wannahang release];
		
		UILabel *lbl_Name = [[UILabel alloc]initWithFrame:CGRectMake(93, 7, 220, 18)];
		lbl_Name.backgroundColor = [UIColor clearColor];
//		lbl_Name.text = @"user 1";
        lbl_Name.numberOfLines = 1;
        lbl_Name.lineBreakMode = UILineBreakModeTailTruncation;
		lbl_Name.font = [UIFont fontWithName:@"helvetica Neue" size:14];
		lbl_Name.font = [UIFont boldSystemFontOfSize:16];
		lbl_Name.textColor = [UIColor darkGrayColor];
		lbl_Name.tag = 3;
		[cell.contentView addSubview:lbl_Name];
		[lbl_Name release];
		
//		UILabel *lbl_wannaHang = [[UILabel alloc]initWithFrame:CGRectMake(93, 25, 180, 20)];
//		[lbl_wannaHang setBackgroundColor:[UIColor clearColor]];
//		lbl_wannaHang.textColor = WannaHangColor;
//		lbl_wannaHang.numberOfLines = 1;
//		lbl_wannaHang.font = [UIFont fontWithName:@"helvetica Neue" size:12];
//		lbl_wannaHang.font = [UIFont boldSystemFontOfSize:12];
//		lbl_wannaHang.tag = 4;
//		[cell.contentView addSubview:lbl_wannaHang];
//		[lbl_wannaHang release];
		
		UILabel *lbl_Age = [[UILabel alloc]initWithFrame:CGRectMake(93, 47, 180, 20)];
		[lbl_Age setBackgroundColor:[UIColor clearColor]];
		lbl_Age.numberOfLines = 2;
		lbl_Age.font = [UIFont fontWithName:@"helvetica Neue" size:12];
		lbl_Age.font = [UIFont boldSystemFontOfSize:12];
		lbl_Age.tag = 5;
		lbl_Age.textColor = [UIColor lightGrayColor];
		[cell.contentView addSubview:lbl_Age];
		[lbl_Age release];
		
	}
	
	TableCellImageView *img_KidPic = (TableCellImageView *)[cell viewWithTag:1];
	UIImageView *img_wannahang = (UIImageView *)[cell viewWithTag:2];
	UILabel *lbl_Name = (UILabel *)[cell viewWithTag:3];
	UILabel *lbl_wannaHang = (UILabel *)[cell viewWithTag:4];
	UILabel *lbl_Age = (UILabel *)[cell viewWithTag:5];
	
	lbl_wannaHang.frame = CGRectMake(74, 25, 180, 20);
	lbl_Age.frame = CGRectMake(74, 43, 180, 20);
	
	NSDictionary *dictData = nil;
	if (self.Searching) {
		dictData = [self.arr_searchParents objectAtIndex:rowIndex];
	}else {
		dictData = [self.arr_listParents objectAtIndex:rowIndex];
	}

//	img_KidPic.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"btn_parents")];
	[img_KidPic setImageUrl:[dictData objectForKey:@"PhotoUrl"]];
	if ([dictData objectForKey:@"txtParentFname"] && [dictData objectForKey:@"txtParentLname"]) {
		lbl_Name.text = [NSString stringWithFormat:@"%@ %@",[dictData objectForKey:@"txtParentFname"],[dictData objectForKey:@"txtParentLname"]];
	}
	
	if ([[dictData objectForKey:@"DegreeCode"] isEqualToString:@"3"]) {
		img_wannahang.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_OutOfKnit")];
	}else if ([[dictData objectForKey:@"DegreeCode"] isEqualToString:@"2"]) {
		img_wannahang.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_OutOfKnit")];
	}else if ([[dictData objectForKey:@"DegreeCode"] isEqualToString:@"1"] || [[dictData objectForKey:@"DegreeCode"] isEqualToString:@"0"]) {
		img_wannahang.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_InKnit")];
		for (NSDictionary *dict in [dictData objectForKey:@"Kids"]) {
			if ([[dict objectForKey:@"txtWannaHang"] isEqualToString:@"t"]) {
				img_wannahang.image =[UIImage imageWithContentsOfFile:getImagePathOfName(@"userStatus_wannaHang")];
				break;
			}
		}
	}
	
	NSString *str = [[[NSString alloc]init] autorelease];
	NSString *kidName = nil;
	NSString *kidAge = nil;

//	NSString *str_wannaHang = [[[NSString alloc]init] autorelease];
//	NSString *kidName_wannaHang = nil;
//	NSString *kidAge_wannaHang = nil;
	
	for (NSDictionary *dict in [dictData objectForKey:@"Kids"]) {
//		if ([[dict objectForKey:@"txtWannaHang"] isEqualToString:@"f"]) {	
			if ([dict objectForKey:@"txtChildFname"]) {
				kidName = [dict objectForKey:@"txtChildFname"];
			}
			if ([dict objectForKey:@"txtChildAge"]) {
				kidAge = [NSString stringWithFormat:@"%@",getChildAge([dict objectForKey:@"txtChildAge"])];
			}
			
			NSString *kid1 = [NSString stringWithFormat:@" | %@ %@",kidName,kidAge];
			str = [str stringByAppendingFormat:@"%@",kid1];		
/*		}else {
			if ([dict objectForKey:@"txtChildFname"]) {
				kidName_wannaHang = [dict objectForKey:@"txtChildFname"];
			}
			if ([dict objectForKey:@"txtChildAge"]) {
				kidAge_wannaHang = [NSString stringWithFormat:@"%@",getChildAge([dict objectForKey:@"txtChildAge"])];
			}
			
			NSString *kid1 = [NSString stringWithFormat:@" | %@ %@",kidName_wannaHang,kidAge_wannaHang];
			str_wannaHang = [str_wannaHang stringByAppendingFormat:@"%@",kid1];		
		}*/
	}
	
	if ([str length] > 2) {
		lbl_Age.text = [str stringByReplacingOccurrencesOfString:@" |" withString:@"" options:0 range:NSMakeRange(0, 2)];
	}else {
		lbl_Age.text = str;
	}
	
//	if (str_wannaHang.length) {
//		lbl_wannaHang.text = [str_wannaHang stringByReplacingOccurrencesOfString:@" |" withString:@"" options:0 range:NSMakeRange(0, 2)];
//	}else {
//		lbl_wannaHang.text = @"";
//	}

	CGSize size = [lbl_wannaHang.text sizeWithFont:lbl_wannaHang.font constrainedToSize:CGSizeMake(180, 15) lineBreakMode:lbl_wannaHang.lineBreakMode];
//	if (lbl_wannaHang.frame.size.height <= 20 || lbl_Age.frame.size.height <= 20 ) {
		img_wannahang.frame = CGRectMake(70, 21, 14, 14);
//    lbl_Name.frame = CGRectMake(87, 20, lbl_Name.frame.size.width, lbl_Name.frame.size.height);
		lbl_Name.frame = CGRectMake(87, 20, 175, lbl_Name.frame.size.height);
//		lbl_wannaHang.frame = CGRectMake( 87, 25+lbl_Name.frame.size.height, size.width, size.height);
		lbl_Age.frame = CGRectMake( 87, 25+lbl_Name.frame.size.height+size.height,180, 15);
/*	}else {
		img_wannahang.frame = CGRectMake(70, 7, 18, 18);
		lbl_Name.frame = CGRectMake(93, 7, 220, 15);
		lbl_wannaHang.frame = CGRectMake( 93, 25, size.width, size.height);
		lbl_Age.frame = CGRectMake( 93, 28 + size.height,180, 15);
	}
*/

	return cell;
}

- (void) calloutButtonClickedOfIndex : (NSMutableDictionary*) dict_index {
	
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	
	ParentDetailViewController *parentDetailViewController = [[ParentDetailViewController alloc]initWithNibName:@"ParentDetailViewController" bundle:nil];
	parentDetailViewController.prevContImage = currentImage;
	parentDetailViewController.parent_ID = [dict_index objectForKey:@"txtUserTblPk"];
	parentDetailViewController.degree_code =[dict_index objectForKey:@"DegreeCode"];
	
	
	if (!self.dict_scheduleData) {
		self.dict_scheduleData = [[NSMutableDictionary alloc] init];
		NSMutableArray *arr_invities = [[NSMutableArray alloc] init];
		NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
		[dict setObject:[dict_index objectForKey:@"txtUserTblPk"] forKey:@"cid"];
		[arr_invities addObject:dict];
		[dict release];
		[self.dict_scheduleData setObject:arr_invities forKey:@"organiserKids"];
		[arr_invities release];
	}else {
		
		NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
		[dict setObject:[dict_index objectForKey:@"txtUserTblPk"] forKey:@"cid"];
		NSMutableArray *arr_invities = [self.dict_scheduleData objectForKey:@"organiserKids"];
		[arr_invities addObject:dict];
		[dict release];
	}		
	
	parentDetailViewController.dict_scheduleData = self.dict_scheduleData;
	parentDetailViewController.spouseDetailsToShow = YES;
	[[DELEGATE nav_playDate] pushViewController:parentDetailViewController animated:NO];
	[parentDetailViewController release];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	UIImage *currentImage = [self captureScreen];
	[self pushingViewController:currentImage];
	ParentDetailViewController *parentDetailViewController = [[ParentDetailViewController alloc]initWithNibName:@"ParentDetailViewController" bundle:nil];
	parentDetailViewController.prevContImage = currentImage;
	parentDetailViewController.spouseDetailsToShow = YES;
	if (!self.dict_scheduleData) {
		self.dict_scheduleData = [[NSMutableDictionary alloc] init];
	}else {
	}		
	
	if (self.Searching) {
		parentDetailViewController.parent_ID = [[self.arr_searchParents objectAtIndex:indexPath.row] objectForKey:@"txtUserTblPk"];
		parentDetailViewController.degree_code = [[self.arr_searchParents objectAtIndex:indexPath.row] objectForKey:@"DegreeCode"];
//		parentDetailViewController.dict_data = [self.arr_searchParents objectAtIndex:indexPath.row];
	}else {
		parentDetailViewController.degree_code = [[self.arr_listParents objectAtIndex:indexPath.row] objectForKey:@"DegreeCode"];
		parentDetailViewController.parent_ID = [[self.arr_listParents objectAtIndex:indexPath.row] objectForKey:@"txtUserTblPk"];
//		parentDetailViewController.dict_data = [self.arr_listParents objectAtIndex:indexPath.row];
	}
	parentDetailViewController.dict_scheduleData = self.dict_scheduleData;
	[[DELEGATE nav_playDate] pushViewController:parentDetailViewController animated:NO];
	[parentDetailViewController release];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -

- (void) addAnnotationToMapView: (BasicMapAnnotation*) annotation {
	[self.mapView addAnnotation:annotation];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:ZIP_CODE_CHANGED object:nil];
	[self.arr_mapParents release];
	[self.arr_listParents release];
	[self.arr_searchParents release];
	[self.theSearchBar release];
	[self.dict_scheduleData release];
	[self.mapView release];
	self.mapView.delegate = nil;
	[api_tyke cancelCurrentRequest];
	[api_tyke release];
	self.loc_currentResults = nil;
    [super dealloc];
}

@end
