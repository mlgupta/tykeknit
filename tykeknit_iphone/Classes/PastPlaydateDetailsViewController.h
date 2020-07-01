//
//  PastPlaydateDetailsViewController.h
//  TykeKnit
//
//  Created by Ver on 20/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"
#import "CustomSegmentView.h"

@interface PastPlaydateDetailsViewController : BaseViewController {
	
	UITableView *theTableView;
	TykeKnitApi *api_tyke;
	NSMutableDictionary *dict_data;
	NSMutableDictionary *dict_participants;
	NSMutableArray *arr_messages;
	NSString *playdate_id;
	UIView *MessageView;
	int heightForFirstMessage;
	UIView *vi_messagesCellView;
}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
//@property(nonatomic,retain) TykeKnitApi *api_tyke;
@property(nonatomic,retain) NSMutableDictionary *dict_data;
@property(nonatomic,retain) UIView *MessageView;
@property(nonatomic,retain) NSMutableDictionary *dict_participants;
@property(nonatomic,retain) NSString *playdate_id;
@property(nonatomic,retain) NSMutableArray *arr_messages;

-(void) addMessageView;
- (CustomSegmentView *)createSegmentViewWithFrame:(CGRect)frame;
-(void) sortParticipants : (NSDictionary *) response;
@end
