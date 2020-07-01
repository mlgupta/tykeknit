//
//  ChangePasswordViewController.h
//  TykeKnit
//
//  Created by Ver on 26/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface ChangePasswordViewController : BaseViewController {

	NSMutableDictionary *dict_userData;
	UITableView *theTableView;
	TykeKnitApi *api_tyke;
}
@property (nonatomic,retain) IBOutlet UITableView *theTableView;
@property (nonatomic,retain) NSMutableDictionary *dict_userData;
@end
