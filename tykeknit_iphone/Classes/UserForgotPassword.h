//
//  UserForgotPassword.h
//  TykeKnit
//
//  Created by Ver on 22/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface UserForgotPassword : BaseViewController {

	UITableView *theTableView;
	NSString *user_email;
	TykeKnitApi *api_tyke;
}

@property (nonatomic,retain) IBOutlet UITableView *theTableView;
@property (nonatomic,retain) NSString *user_email;
@property (nonatomic,retain) TykeKnitApi *api_tyke;
@end
