//
//  SelectFriendsViewController.h
//  TykeKnit
//
//  Created by Ver on 14/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface SelectFriendsViewController : BaseViewController {
	
	NSMutableArray *arr_data;
	NSMutableArray *arr_friendsData;
	NSMutableDictionary *dict_messageData;
	IBOutlet UITableView *theTableView;
	TykeKnitApi *api_tyke;
}
@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) NSMutableDictionary *dict_messageData;
@property (nonatomic,retain) NSMutableArray *arr_friendsData;
@property (nonatomic,retain) TykeKnitApi *api_tyke;

- (void) selectChild:(id)sender;
@end
