//
//  PastPlaydatesViewController.h
//  TykeKnit
//
//  Created by Ver on 08/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface PastPlaydatesViewController : BaseViewController {

	UITableView *theTableView;
	TykeKnitApi *api_tyke;
	NSMutableDictionary *dict_data;
}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
@property(nonatomic,retain) TykeKnitApi *api_tyke;
@property(nonatomic,retain) NSMutableDictionary *dict_data;
@end
