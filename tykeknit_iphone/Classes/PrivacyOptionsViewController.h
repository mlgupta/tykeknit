//
//  PrivacyOptionsViewController.h
//  TykeKnit
//
//  Created by Abhinav Singh on 16/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface PrivacyOptionsViewController : BaseViewController {
	NSMutableDictionary *dict_settingsOption;
	NSString *currentKey;

	TykeKnitApi *api_tyke;

	UITableView *theTableView;
}

@property(nonatomic, retain) IBOutlet UITableView *theTableView;
@property(nonatomic, retain) NSMutableDictionary *dict_settingsOption;
@property(nonatomic, retain) NSString *currentKey;
@property(nonatomic, retain) TykeKnitApi *api_tyke;


@end
