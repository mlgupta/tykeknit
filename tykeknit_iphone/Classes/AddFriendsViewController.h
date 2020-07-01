//
//  AddFriendsViewController.h
//  TykeKnit
//
//  Created by Ver on 13/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "FaceBookEngine.h"
#import "TykeKnitApi.h"


@interface AddFriendsViewController :BaseViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, FaceBookEngineDelegate,UIAlertViewDelegate>{
	UIView *topView;
	UIView *middleView;	
	IBOutlet UITableView *theTableView;
	
	UIImageView *rightSideView;
	NSInteger friendsCount;
	NSMutableArray *arr_fbFriendsInfo;
	NSArray *friendsArray;
    
    NSMutableDictionary *dictUserInfo;

    TykeKnitApi *api;

}

@property (nonatomic, retain) UIView *topView;
@property (nonatomic, retain) UIView *middleView;
@property (nonatomic, retain) NSArray *friendsArray;
@property (nonatomic, retain) NSMutableArray *arr_fbFriendsInfo;
@property (nonatomic) NSInteger friendsCount;
@property (nonatomic, retain) UIImageView *rightSideView;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
//- (void) loadAddFacebookFriendViewController: (id) semder;
//- (void) loadAddAddressBookFriendViewController: (id) sender;
@property(nonatomic, retain) NSMutableDictionary *dictUserInfo;
@property (nonatomic, retain) TykeKnitApi *api;


@end
