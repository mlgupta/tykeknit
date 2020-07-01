//
//  AccountInfoViewController.h
//  TykeKnit
//
//  Created by Abhinav Singh on 07/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "RightSideView.h"
#import "TykeKnitApi.h"

@interface AccountInfoViewController : BaseViewController <RightSideViewDelegate,UIAlertViewDelegate>{
	UITableView *theTableView;
	NSMutableDictionary *dict_settings;
	NSMutableDictionary *dict_userData;
	RightSideView *rightSideView;
	TykeKnitApi *api_tyke;
	FacebookAPI *api_facebook;
}

@property(nonatomic, retain) NSMutableDictionary *dict_settings;
@property (nonatomic, retain) IBOutlet UITableView *theTableView;
@property (nonatomic, retain) RightSideView *rightSideView;
@property (nonatomic, retain) NSMutableDictionary *dict_userData;
@property (nonatomic, retain) TykeKnitApi *api_tyke;

@end
