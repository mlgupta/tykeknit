//
//  userAuthentication.h
//  TykeKnit
//
//  Created by Ver on 22/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface userAuthentication : BaseViewController <UIAlertViewDelegate>{

	UITableView *theTableView;
	TykeKnitApi *api_tyke;
	NSMutableDictionary *dict_loginInfo;
}
@property (nonatomic,retain) IBOutlet UITableView *theTableView;
@property (nonatomic,retain) NSMutableDictionary *dict_loginInfo;
@end
