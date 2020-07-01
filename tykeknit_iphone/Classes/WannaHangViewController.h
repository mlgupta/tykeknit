//
//  WannaHangViewController.h
//  TykeKnit
//
//  Created by Ver on 28/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "TykeKnitApi.h"
#import "UIPlaceHolderTextView.h"
#import "BaseViewController.h"

@interface WannaHangViewController : BaseViewController <UITableViewDelegate,UITableViewDataSource,UITextViewDelegate> {

	TykeKnitApi *api_Tyke;
	NSMutableArray *arr_Data;
	NSMutableArray *arr_updatedData;
    NSMutableDictionary *dict_msgData;
    UITableView *theTableView;
    float animatedDistance;
    UIPlaceHolderTextView *MessageView;
}

@property (nonatomic,retain) TykeKnitApi *api_Tyke;
@property (nonatomic,retain) NSMutableArray *arr_Data;
@property (nonatomic,retain) NSMutableArray *arr_updatedData;
@property (nonatomic,retain) NSMutableDictionary *dict_msgData;
@property (nonatomic,retain) UITableView *theTableView;
@property (nonatomic,retain) UIPlaceHolderTextView *MessageView;

@end
