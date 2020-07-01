//
//  PlaydateDetailViewController.h
//  TykeKnit
//
//  Created by Ver on 08/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"
#import "CustomSegmentView.h"

@interface PlaydateDetailViewController : BaseViewController <UITextViewDelegate>{

	UITableView *theTableView;
	TykeKnitApi *api_tyke;
	NSMutableDictionary *dict_data;
	NSMutableDictionary *dict_participants;
	NSMutableArray *arr_messages;
	NSString *playdate_id;
	UIView *MessageView;
	int heightForFirstMessage;
	UIView *vi_messagesCellView;
	BOOL RSVPAccepted;
}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
//@property(nonatomic,retain) TykeKnitApi *api_tyke;
@property(nonatomic,retain) NSMutableDictionary *dict_data;
@property(nonatomic,retain) UIView *MessageView;
@property(nonatomic,retain) NSMutableDictionary *dict_participants;
@property(nonatomic,retain) NSString *playdate_id;
@property(nonatomic,retain) NSMutableArray *arr_messages;
@property(nonatomic,readwrite) BOOL RSVPAccepted;

-(void) addMessageView;
- (CustomSegmentView *)createSegmentViewWithFrame:(CGRect)frame;
-(void) sortParticipants : (NSDictionary *) response;
//- (CGSize) getHeightForCellAtIndex : (NSIndexPath) indexPath;
@end
