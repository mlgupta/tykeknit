//
//  emailComposeVC.h
//  TykeKnit
//
//  Created by Abhinit Tiwari on 18/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"
#import "Global.h"
#import "TykeKnitApi.h"


@interface InviteFriendsEmailViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate> {
	
	UITableView *theTableView;
	UIImageView *rightSideView;
	NSMutableDictionary *dict_Invitees;
	TykeKnitApi *api;
	int numberOfRows;
	float animatedDistance;
	BOOL areAllEmailIdValid;
}

@property (nonatomic,retain) IBOutlet UITableView *theTableView;
@property (nonatomic,retain) UIImageView *rightSideView;
@property (nonatomic,retain) NSMutableDictionary *dict_Invitees;
@property (nonatomic,readwrite) BOOL areAllEmailIdValid;
@end
