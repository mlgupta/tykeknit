//
//  EventDetailViewController.h
//  TykeKnit
//
//  Created by Manish Gupta on 21/06/11.
//  Copyright 2011 Tykeknit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"


@interface EventDetailViewController : BaseViewController <UITextViewDelegate>{

    UITableView *theTableView;
	TykeKnitApi *api_tyke;
	NSMutableDictionary *dict_data;
	NSMutableArray *arr_messages;
	UIView *MessageView;
	int heightForFirstMessage;
	UIView *vi_messagesCellView;

}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
@property(nonatomic,retain) NSMutableDictionary *dict_data;
@property(nonatomic,retain) UIView *MessageView;
@property(nonatomic,retain) NSMutableArray *arr_messages;

-(void) addMessageView;
@end
