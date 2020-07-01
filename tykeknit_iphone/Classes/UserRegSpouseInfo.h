//
//  UserRegSpouseInfo.h
//  TykeKnit
//
//  Created by Ver on 14/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "BaseViewController.h"

@interface UserRegSpouseInfo : BaseViewController <UITableViewDelegate, UITableViewDataSource>{

	UIImageView *rightSideView;
	UITableView *theTableView;
}
@property (nonatomic,retain) UIImageView *rightSideView;
@property (nonatomic,retain) IBOutlet UITableView *theTableView;
@end
