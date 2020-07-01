//
//  PlaydateNotificationViewController.h
//  TykeKnit
//
//  Created by Ver on 27/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface PlaydateNotificationViewController : BaseViewController {
	
	IBOutlet UITableView *theTableView;
	NSMutableArray *arr_Data;
	
}
@property(nonatomic,retain)	IBOutlet UITableView *theTableView;
@property(nonatomic,retain)	NSMutableArray *arr_Data;
@end
