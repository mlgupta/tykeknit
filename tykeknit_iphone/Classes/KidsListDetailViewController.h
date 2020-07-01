//
//  KidsListDetailViewController.h
//  TykeKnit
//
//  Created by Ver on 23/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface KidsListDetailViewController :BaseViewController  {
	
	IBOutlet UITableView *theTableView;
	BOOL loadingRequest;
	NSMutableDictionary *dict_scheduleData;
	BOOL isWannaHang;
	
	
	//Response Data
	NSMutableDictionary *dict_Data;
	NSString *child_id;
	TykeKnitApi *api_tyke;
}

@property (nonatomic,assign) BOOL isWannaHang;
@property (nonatomic,retain) NSString *child_id;
@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) NSMutableDictionary *dict_scheduleData;
//@property (nonatomic,retain) NSMutableArray *arr_Invities;
@property (nonatomic,retain) NSMutableDictionary *dict_Data;
- (NSString *) dateFormatter:(NSIndexPath *) indexPath;

@end
