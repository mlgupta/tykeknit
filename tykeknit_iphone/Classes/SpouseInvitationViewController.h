//
//  SpouseInvitationViewController.h
//  TykeKnit
//
//  Created by Ver on 24/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"


@interface SpouseInvitationViewController : BaseViewController {
	UITableView *theTableView;
	NSString *str_spouseEmail;
	TykeKnitApi *api;
	int numberOfRows;
	float animatedDistance;
}

@property (nonatomic,retain) IBOutlet UITableView *theTableView;
@property (nonatomic,retain) NSString *str_spouseEmail;
@end
