//
//  LoginViewController.h
//  TykeKnit
//
//  Created by Abhinav Singh on 02/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface LoginViewController : BaseViewController <UIAlertViewDelegate>{
	UITableView *theTableView;
	NSMutableDictionary *dict_loginInfo;
	UIImageView *rightSideView;
	TykeKnitApi *api_tyke; 
}

@property (nonatomic, retain) NSMutableDictionary *dict_loginInfo;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) UIImageView *rightSideView;
- (void) btn_LoginPressed : (id) sender;
- (void) funJoinNow : (id) sender;
- (void) btn_ForgotPasswordPressed : (id) sender;
@end
