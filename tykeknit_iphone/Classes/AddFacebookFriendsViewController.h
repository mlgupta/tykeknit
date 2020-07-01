//
//  AddFacebookFriendsViewController.h
//  SpotWorld
//
//  Created by Abhinit Tiwari on 14/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookAPI.h"
#import "BaseViewController.h"
#import "FaceBookEngine.h"
#import "TykeKnitApi.h"
@interface AddFacebookFriendsViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource,FaceBookEngineDelegate> {
	NSInteger friendsCount;
	NSArray *friendsArray;
	NSMutableArray *friendsArray1;
	NSMutableDictionary *dict_selectedFriends;
	UIView *topView;
	UIView *middleView;
	UITableView *theTableView;
	NSMutableArray *selectedIndexes;
	
	TykeKnitApi *api;
	
	NSInteger currentReq;
    
    BOOL userhasFBFriends;
}
@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UIView *middleView;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic) NSInteger friendsCount;
@property (nonatomic) BOOL userhasFBFriends;
@property (nonatomic, retain) NSArray *friendsArray;
@property (nonatomic, retain) NSMutableArray *friendsArray1;
@property (nonatomic, retain) NSMutableDictionary *dict_selectedFriends;
@property (nonatomic, retain) TykeKnitApi *api;
@end