//
//  PlaydateScheduleDateTimeViewController.h
//  TykeKnit
//
//  Created by Ver on 06/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"


@interface PlaydateScheduleDateTimeViewController : BaseViewController {

	UITableView *theTableView;
	NSMutableDictionary *dict_scheduleData;
}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
@property(nonatomic,retain) NSMutableDictionary *dict_scheduleData;
- (void) showPickerFor :(NSString*) type;
@end
