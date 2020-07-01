//
//  EventsViewController.h
//  TykeKnit
//
//  Created by Ver on 07/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "RightSideView.h"
#import "TykeKnitApi.h"
#import "CustomSegmentView.h"
#import "EGORefreshTableHeaderView.h"

@interface EventsViewController : BaseViewController <EGORefreshTableHeaderDelegate, RightSideViewDelegate>{

	UITableView *theTableView;
    EGORefreshTableHeaderView *_refreshHeaderView;
	TykeKnitApi *api_tyke;
	NSMutableArray *arr_data;
	NSIndexPath *selectedIndexPath;
	BOOL RemoveRow;
    BOOL _reloading;
}
@property (nonatomic,retain) IBOutlet UITableView *theTableView;
@property (nonatomic,retain) TykeKnitApi *api_tyke;
@property (nonatomic,retain) NSMutableArray *arr_data;
@property (nonatomic,retain) NSIndexPath *selectedIndexPath;
@property (nonatomic,retain) UIView *swipeView;
@property (nonatomic,readwrite) BOOL toReload;
@property (nonatomic,readwrite) BOOL RemoveRow;

- (NSString *) dateFormatter:(NSIndexPath *) indexPath;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end

