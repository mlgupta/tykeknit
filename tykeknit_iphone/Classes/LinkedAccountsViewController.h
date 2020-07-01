//
//  LinkedAccountsViewController.h
//  TykeKnit
//
//  Created by Abhinav Singh on 08/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "FacebookAPI.h"

@interface LinkedAccountsViewController : BaseViewController <FacebookAPIDelegate>{
	UITableView *theTableView;
	NSMutableDictionary *dict_settings;
	FacebookAPI *api_facebook;
}

@property(nonatomic, retain) NSMutableDictionary *dict_settings;
@property(nonatomic, retain) IBOutlet UITableView *theTableView;
@property(nonatomic, retain) FacebookAPI *api_facebook; 

@end
