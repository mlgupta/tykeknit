//
//  MyFriendsDetailViewController.h
//  TykeKnit
//
//  Created by Ver on 14/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface MyFriendsDetailViewController : BaseViewController {
	
	UITableView *theTableView;
	NSString *friendId;
	NSString *degree;
	NSMutableDictionary *dict_data;
	TykeKnitApi *api_tyke;
}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
@property(nonatomic,retain) NSString *friendId;
@property(nonatomic,retain) NSString *degree;
@property(nonatomic,retain) NSMutableDictionary *dict_data;
@property(nonatomic,retain) TykeKnitApi *api_tyke;
@end
