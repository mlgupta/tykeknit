//
//  PlaydateScheduleKidsViewController.h
//  TykeKnit
//
//  Created by Ver on 24/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface PlaydateScheduleKidsViewController : BaseViewController {
	
	IBOutlet UITableView *theTableView;
	IBOutlet UILabel *lbl_errorMsg;
	NSMutableDictionary *dict_scheduleData;
    
	TykeKnitApi *api_tyke;

	NSString *child_id;
    NSString *selectedBuddy;
    NSMutableIndexSet *expandedSections;
	
	NSMutableArray *arr_wannaHang;
	NSMutableArray *arr_inKnit;
}

@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) NSMutableDictionary *dict_scheduleData;
@property (nonatomic,retain) TykeKnitApi *api_tyke;
@property (nonatomic,retain) NSString *child_id;
@property (nonatomic,retain) NSString *selectedBuddy;
@property (nonatomic,readwrite) BOOL onlyParents;

- (void) sortBuddies;
@end
