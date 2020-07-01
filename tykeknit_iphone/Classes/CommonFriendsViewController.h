//
//  CommonFriendsViewController.h
//  TykeKnit
//
//  Created by Ver on 05/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CommonFriendsViewController : BaseViewController {
	
	UITableView *theTableView;
	NSMutableArray *arr_friendsData;
	
}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
@property(nonatomic,retain) NSMutableArray *arr_friendsData;
@end
