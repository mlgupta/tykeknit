//
//  ParentsDetailViewController.h
//  TykeKnit
//
//  Created by Abhinav Singh on 13/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface ParentsDetailViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>{
	UITableView *theTableView;
	NSMutableDictionary *dict_userData;
	NSMutableArray *arr_emails;
	TykeKnitApi *api_tyke;
	
	float animatedDistance;
	BOOL valuesUpdated;
	BOOL isImageSet;
	BOOL zipCodeChanged;

}


@property(nonatomic, retain) IBOutlet UITableView *theTableView;
@property(nonatomic, retain) NSMutableArray *arr_emails;
@property(nonatomic, retain) NSMutableDictionary *dict_userData;
@property(nonatomic, retain) UIView *vi_photoShadow;
@property(nonatomic, retain) UIButton *photoImageView;
@property(nonatomic, readwrite) BOOL valuesUpdated;
@property(nonatomic, readwrite) BOOL zipCodeChanged;
- (void) selectImage;
//@property(nonatomic, retain) TykeKnitApi *api_tyke;
@end
