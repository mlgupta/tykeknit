//
//  UserRegStepOne.h
//  TykeKnit
//
//  Created by Abhinit Tiwari on 06/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "TykeKnitApi.h"
#define PARTNER_SECTION 0
#define PHOTO_INDENT 74.0


@interface UserRegStepOne : BaseViewController<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {

	float animatedDistance;
	BOOL isImageSet;
	
	UITableView *regStepOneTV;
	NSMutableDictionary *dictParentsData;
	UIImageView *parentsPhotoIV;
	UIButton *btnImage;
	UIImageView *rightSideView;
		
	TykeKnitApi *api_tyke;
	BOOL isUserRegistered;
	NSInteger noOfSections;
	
	UIView *vi_photoShadow;
	UIButton *photoImageView;
}

@property (nonatomic, retain) IBOutlet UITableView *regStepOneTV;
@property (nonatomic, retain) UIButton *btnImage;
@property (nonatomic,retain) UIImageView *rightSideView;
@property (nonatomic, retain) NSMutableDictionary *dictParentsData;
@property (nonatomic, retain) UIView *vi_photoShadow;
@property (nonatomic, retain) UIButton *photoImageView;


- (void) funTermsAndCondition:(id) sender;
- (void) verifyPassword : (NSString *) password;
- (void) editingStart : (id) sender; 
- (void) nextPressed : (id) sender;
- (void) editingEnded : (id) sender;
- (void) selectImage : (id) sender;
- (BOOL) isFormValid;
@end
