//
//  PlayDateViewController.h
//  TykeKnit
//
//  Created by Abhinav Singh on 23/11/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import "BaseViewController.h"
#import "TykeKnitApi.h"
#import "CalloutMapAnnotation.h"
#import "CalloutMapAnnotationView.h"
#import "BasicMapAnnotation.h"
#import "ValuesSelectionView.h"
#import "PlaydateTabbar.h"
#import "RightSideView.h"

@interface PlayDateViewController : BaseViewController <MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource,
CallOutMapAnnotationDelegate, PlaydateTabbarDelegate,RightSideViewDelegate,UISearchBarDelegate,
UIAlertViewDelegate>{
	MKMapView *mapView;
	TykeKnitApi *api_tyke;
	RightSideView *rightSideView;
	NSMutableArray *arr_mapParents;
	NSMutableArray *arr_listParents;
	NSMutableArray *arr_searchParents;
	BOOL loadingRequest;
///	NSMutableDictionary *dict_requestdetails;
	CalloutMapAnnotation *calloutAnnotation;
	MKAnnotationView *selectedAnnotion;
	UITableView *theTableView;
	NSMutableDictionary *dict_scheduleData;
	ValuesSelectionView *vi_valuesSelection;
	PlaydateTabbar *filter_tabBar;
	UISearchBar *theSearchBar;
	UIButton *btn_back;
	CLLocation *loc_currentResults;
	NSDate *latestUserPositionUpdated;
	BOOL ListViewOn;
	UIView *reloadView;
	BOOL Searching;
	BOOL BullsEyeClicked;
	BOOL reloadButtonShown;
	BOOL reloadButtonTriggerOn;
	BOOL annotationViewShown;
	BOOL filterIsOn;
	BOOL animatingTransform;
}

@property(nonatomic, retain) MKAnnotationView *selectedAnnotion;
@property(nonatomic, retain) CalloutMapAnnotation *calloutAnnotation;
@property(nonatomic, retain) RightSideView *rightSideView;
@property(nonatomic, retain) PlaydateTabbar *filter_tabBar;
@property(nonatomic, retain) NSMutableArray *arr_mapParents;
@property(nonatomic, retain) NSMutableArray *arr_listParents;
@property(nonatomic, retain) NSMutableArray *arr_searchParents;
//@property(nonatomic, retain) NSMutableDictionary *dict_requestdetails;
@property(nonatomic, retain) MKMapView *mapView;
@property(nonatomic, retain) NSMutableDictionary *dict_scheduleData;
@property(nonatomic, retain) UITableView *theTableView;
@property(nonatomic, retain) TykeKnitApi *api_tyke;
@property(nonatomic, retain) UIButton *btn_back;
@property(nonatomic, retain) UISearchBar *theSearchBar;
@property(nonatomic, retain) CLLocation *loc_currentResults;
@property(nonatomic, retain) NSDate *latestUserPositionUpdated;
@property(nonatomic, retain) IBOutlet UIView *reloadView;
@property(nonatomic, readwrite)	BOOL ListViewOn;
@property(nonatomic, readwrite)	BOOL annotationViewShown;
@property(nonatomic, readwrite)	BOOL BullsEyeClicked;
@property(nonatomic, readwrite)	BOOL reloadButtonShown;
@property(nonatomic, readwrite) BOOL reloadButtonTriggerOn;
@property(nonatomic, readwrite)	BOOL Searching;
@property(nonatomic, readwrite)	BOOL filterIsOn;
@property(nonatomic, readwrite)	BOOL loadingRequest;

- (void) addAnnotationToMapView: (BasicMapAnnotation*) annotation;
- (void) reloadBUttonClicked : (id) sender;
- (void) reloadMapData;
- (void) showReloadButton;
-(void) removeReloadButton;
- (void) valuesSelectionCompleted : (NSMutableArray*)arrselectedValues TypeOf:(NSString*)str_typeOf;
- (void)bullsEye:(id) sender;
- (CGFloat) getMapRadius;
@end
