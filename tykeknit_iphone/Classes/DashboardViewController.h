//
//  DashboardViewController.h
//  TykeKnit
//
//  Created by Abhinav Singh on 23/11/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "RightSideView.h"
#import "TykeKnitApi.h"
#import "TableCellImageView.h"

@interface DashboardViewController : BaseViewController <RightSideViewDelegate>{
	UITableView *theTableView;
	IBOutlet UISearchBar *searchBar;
	NSMutableDictionary *dict_data;
	TykeKnitApi *api_tyke;
	TableCellImageView *profilePic;
    BOOL noUpcomingPlaydates;
}

@property(nonatomic, retain) IBOutlet UITableView *theTableView;
@property(nonatomic, retain) TykeKnitApi *api_tyke;
@property(nonatomic, retain) NSMutableDictionary *dict_data;
@property(nonatomic, retain) TableCellImageView *profilePic;
- (void) cancelSearch;

@end
