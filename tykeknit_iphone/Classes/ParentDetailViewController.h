//
//  ParentDetailViewController.h
//  TykeKnit
//
//  Created by Ver on 17/02/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface ParentDetailViewController : BaseViewController {

	UITableView *theTableView;
	NSMutableDictionary *dict_data;
	NSString *degree_code;
	NSString *parent_ID;
	BOOL spouseDetailsToShow;
	NSMutableDictionary *dict_scheduleData;
	TykeKnitApi *api_tyke;
}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
@property(nonatomic,retain) NSMutableDictionary *dict_data;
@property(nonatomic,retain) NSString *parent_ID;
@property(nonatomic,retain) NSString *degree_code;
@property(nonatomic,retain) NSMutableDictionary *dict_scheduleData;
@property(nonatomic,retain) TykeKnitApi *api_tyke;
@property(nonatomic,readwrite) BOOL spouseDetailsToShow;

- (void) reloadForSpouse : (NSString *)spouse_id;
@end
