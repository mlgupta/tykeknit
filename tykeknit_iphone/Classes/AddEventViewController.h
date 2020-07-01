//
//  AddEventViewController.h
//  TykeKnit
//
//  Created by Manish Gupta on 21/06/11.
//  Copyright 2011 Tykeknit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "UIPlaceHolderTextView.h"
#import "TykeKnitApi.h"


@interface AddEventViewController : BaseViewController <UITextViewDelegate>{

    IBOutlet UITableView *theTableView;
	NSMutableDictionary *dict_eventData;
	NSMutableArray *arr_eventData;
	UIPlaceHolderTextView *MessageView;
	float animatedDistance;
	TykeKnitApi *api_tyke;
}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
@property (nonatomic,retain) NSMutableArray *arr_eventData;
@property (nonatomic,retain) NSMutableDictionary *dict_eventData;
@property (nonatomic,retain) UIPlaceHolderTextView *MessageView;
@property(nonatomic,retain) TykeKnitApi *api_tyke;

@end
