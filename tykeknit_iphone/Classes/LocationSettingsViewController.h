//
//  LocationSettingsViewController.h
//  TykeKnit
//
//  Created by Abhinav Singh on 08/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface LocationSettingsViewController : BaseViewController {
	UITableView *theTableView;
	NSMutableDictionary *dict_settings;
	TykeKnitApi *api_tyke;
}

@property(nonatomic, retain) NSMutableDictionary *dict_settings;
@property(nonatomic, retain) IBOutlet UITableView *theTableView;
@property(nonatomic, retain) TykeKnitApi *api_tyke;

@end
