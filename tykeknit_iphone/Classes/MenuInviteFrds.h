//
//  MenuInviteFrds.h
//  TykeKnit
//
//  Created by Abhinit Tiwari on 18/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MenuInviteFrds : UIViewController<UITableViewDelegate, UITableViewDataSource> {
	
	UITableView *menuTable;
	
	NSMutableArray *arrMenuNames;
	NSMutableArray *arrImgMenuNames;
}

@property(nonatomic, retain) IBOutlet UITableView *menuTable;
@property(nonatomic, retain) NSMutableArray *arrMenuNames;
@property(nonatomic, retain) NSMutableArray *arrImgMenuNames;
@end
