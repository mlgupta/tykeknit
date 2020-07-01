//
//  AddAddressbookFriendsViewController.h
//  SpotWorld
//
//  Created by Abhinit Tiwari on 15/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"
@interface AddAddressbookFriendsViewController : BaseViewController <UITableViewDelegate,UITableViewDataSource> {
	NSInteger friendsCount;
	NSMutableArray *addressBook_Friends;
	NSMutableArray *tyke_friends;
	NSMutableArray *simple_friends;
	NSMutableDictionary *dict_selectedFriends;
	
	NSMutableSet *selectedFriends;

	NSUInteger NoOfFriendsToUpdate;
	UITableView *theTableView;
	TykeKnitApi *api;
	BOOL isDryRun;
}

@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic) NSInteger friendsCount;
@property (nonatomic) NSUInteger NoOfFriendsToUpdate;
@property (nonatomic, retain) NSMutableArray *simple_friends;
@property (nonatomic, retain) NSMutableArray *tyke_friends;
@property (nonatomic, retain) NSMutableArray *addressBook_Friends;
@property (nonatomic, retain) NSMutableDictionary *dict_selectedFriends;
@property (nonatomic,readwrite)	BOOL isDryRun;

- (NSMutableArray *)getPersonNames;
- (void) selectChild:(id)sender;

@end