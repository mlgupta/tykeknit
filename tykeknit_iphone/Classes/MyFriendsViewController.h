//
//  MyFriendsViewController.h
//  TykeKnit
//
//  Created by Ver on 11/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface MyFriendsViewController : BaseViewController {
	
	UITableView *theTableView;
	TykeKnitApi *api_tyke;
	NSMutableArray *arr_friendsData;

}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
@property(nonatomic,retain) TykeKnitApi *api_tyke;
@property(nonatomic,retain) NSMutableArray *arr_friendsData;
@end
