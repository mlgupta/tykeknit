//
//  InvitersProfileViewController.h
//  TykeKnit
//
//  Created by Ver on 22/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface InvitersProfileViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>{

		IBOutlet UITableView *theTableView;
//		NSMutableArray *arr_Data;
	NSMutableDictionary *dict_Data;
}

@property(nonatomic,retain)	NSMutableDictionary *dict_Data;
@property(nonatomic,retain)	IBOutlet UITableView *theTableView;
//@property(nonatomic,retain)	NSMutableArray *arr_Data;
@end
