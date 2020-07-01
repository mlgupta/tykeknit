//
//  ComposeMailViewController.h
//  TykeKnit
//
//  Created by Ver on 11/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"


@interface ComposeMailViewController : BaseViewController <UITextViewDelegate>{

	UITableView *theTableView;
	TykeKnitApi *api_tyke;
	NSString *replyToID;
	NSString *replyToName;
	NSString *msgSubject;
	NSMutableDictionary *dict_messageData;
	float animatedDistance;
	UITextView *msgTextView;
	
}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
@property(nonatomic,retain) TykeKnitApi *api_tyke;
@property(nonatomic,retain) NSString *replyToID;
@property(nonatomic,retain) NSString *msgSubject;
@property(nonatomic,retain) NSString *replyToName;
@property(nonatomic,retain) NSMutableDictionary *dict_messageData;
@property(nonatomic,retain) UITextView *msgTextView;
@end
