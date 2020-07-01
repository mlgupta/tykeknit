//
//  EditKidsDetailsViewController.h
//  TykeKnit
//
//  Created by Ver on 01/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"

@interface EditKidsDetailsViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextFieldDelegate>{

	UITableView *theTableView;
	NSString *child_id;
	NSMutableDictionary *dict_data;
	UIView *vi_photoShadow;
	UIButton *photoImageView;
	TykeKnitApi *api_tyke;
	float animatedDistance;
	BOOL isImageSet;
	BOOL valuesUpdated;

}
@property(nonatomic,retain) IBOutlet UITableView *theTableView;
@property(nonatomic,retain) NSString *child_id;
@property(nonatomic,retain) NSMutableDictionary *dict_data;
@property(nonatomic, retain) UIView *vi_photoShadow;
@property(nonatomic, retain) UIButton *photoImageView;
@property(nonatomic, retain) TykeKnitApi *api_tyke;
@property(nonatomic, readwrite) BOOL valuesUpdated;
- (void) selectImage;
@end
