//
//  MessagesViewController.h
//  TykeKnit
//
//  Created by Ver on 07/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"
#import "CustomSegmentView.h"

@interface MessagesViewController : BaseViewController<CustomSegmentViewDelegate> {

	UITableView *theTableView;
	TykeKnitApi *api_tyke;
	NSMutableArray *arr_data;
	int selectedMessage;
	int selectMessageForDelete;
	BOOL toEdit;
	BOOL toReload;
	NSIndexPath *selectedIndexPath;
	UIView *swipeView;
	BOOL RemoveRow;
}
@property (nonatomic,retain) IBOutlet UITableView *theTableView;
@property (nonatomic,retain) TykeKnitApi *api_tyke;
@property (nonatomic,retain) NSMutableArray *arr_data;
@property (nonatomic,retain) NSIndexPath *selectedIndexPath;
@property (nonatomic,retain) UIView *swipeView;
@property (nonatomic,readwrite) BOOL toReload;
@property (nonatomic,readwrite) BOOL RemoveRow;

- (NSString *) dateFormatter:(NSIndexPath *) indexPath;
- (void) createSegmentViewWithType : (NSString *)msgtype onCell:(UITableViewCell *)cell;
- (void) selectMessage:(id)sender;
@end


//for deleting message i need selected message.
//for removing swipe view do i need selected message ?
// on click the selected message unread status should get changed to read message.
