//
//  PlaydateScheduleViewController.h
//  TykeKnit
//
//  Created by Ver on 24/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface PlaydateScheduleViewController : BaseViewController <ABPeoplePickerNavigationControllerDelegate,UITextViewDelegate>{

	IBOutlet UITableView *theTableView;
	NSMutableDictionary *dict_scheduleData;
	NSMutableDictionary *dict_kidData;
	NSMutableArray *arr_kidData;
	NSString *selectedBuddy;
	UIView *MessageView;
	TykeKnitApi *api_tyke;
}

@property (nonatomic,retain) NSMutableArray *arr_invities;
@property (nonatomic,retain) NSMutableArray *arr_kidData;
@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) NSString *selectedBuddy;
@property (nonatomic,retain) NSMutableDictionary *dict_scheduleData;
@property (nonatomic,retain) UIView *MessageView;
@property (nonatomic,retain) NSMutableDictionary *dict_kidData;

-(void) addMessageView;
- (void) selectChild:(id)sender;
@end
