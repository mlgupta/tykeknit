//
//  MessageDetailViewController.h
//  TykeKnit
//
//  Created by Ver on 12/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"
#import "CustomSegmentView.h"

@interface MessageDetailViewController : BaseViewController <CustomSegmentViewDelegate>{

	UITableView *theTableView;
	NSMutableDictionary *dict_prevData;
	NSString *msgID;
	NSString *msgType;
	NSString *msgStatus;
	TykeKnitApi *api_tyke;
	NSMutableDictionary *dict_messageData;
	UIImageView *bottomTabbar;
	BOOL RSVPAccepted;
}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
@property(nonatomic,retain) NSString *msgID;
@property(nonatomic,retain) NSString *msgType;
@property(nonatomic,retain) NSString *msgStatus;
@property(nonatomic,retain) NSMutableDictionary *dict_prevData;
@property(nonatomic,retain) TykeKnitApi *api_tyke;
@property(nonatomic,retain) NSMutableDictionary *dict_messageData;
@property(nonatomic,retain) UIImageView *bottomTabbar;
@property(nonatomic,readwrite) BOOL RSVPAccepted;

- (CustomSegmentView*) getSegmentViewWithType : (NSString *)msgtype;
- (void) addBottomTabbarForType:(NSString *)messageType;
@end
