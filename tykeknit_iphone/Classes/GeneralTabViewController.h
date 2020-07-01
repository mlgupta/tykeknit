//
//  GeneralTabViewController.h
//  TykeKnit
//
//  Created by Ver on 23/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface GeneralTabViewController : BaseViewController {

	UITableView *theTableView;
	NSMutableDictionary *dict_settings;
	TykeKnitApi *api_tyke;
	BOOL isValueChanged;
}
@property (nonatomic,retain) IBOutlet UITableView *theTableView;
@property (nonatomic,retain) NSMutableDictionary *dict_settings;
@property (nonatomic,readwrite) BOOL isValueChanged;
@end
