//
//  UserRegStepTwo.h
//  TykeKnit
//
//  Created by Abhinit Tiwari on 06/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TykeKnitApi.h"
#import "BaseViewController.h"

#define PARTNER_SECTION 0
#define PHOTO_INDENT 74.0

@interface UserRegStepTwo : BaseViewController<UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate,UIAlertViewDelegate> {
	
	float animatedDistance;
	UITableView *regStepTwoTV;
	UIImageView *rightSideView;
	UIButton *btn_addMoreTyke;
	
	NSMutableDictionary *ParentsData;
	NSMutableDictionary *dictTykeData;
	NSMutableDictionary *dict_Settings; 
	NSInteger noOfSections;
	
	int currentSectionIndex;
	int numberOfSections;
	TykeKnitApi *api_tyke;
	BOOL currentChildAdded;
	
	BOOL wantToAddmorechild;
}

@property (nonatomic, retain) IBOutlet UITableView *regStepTwoTV;
@property (nonatomic, retain) UIImageView *rightSideView;
@property (nonatomic, retain) UIButton *btn_addMoreTyke;
@property (nonatomic, retain) NSMutableDictionary *ParentsData;
@property (nonatomic, retain) NSMutableDictionary *dictTykeData;
@property (nonatomic, retain) NSMutableDictionary *dict_Settings;


- (void) funBackButtonClicked : (id) sender; 
- (void) saveDate:(UIButton *)btnDone;
- (void) selBirthDate: (id) sender;
- (void) editingStart : (id) sender; 
- (void) nextPressed : (id) sender;
- (void) editingEnded : (id) sender;
- (void) funAddMoreTyke : (id) sender;
- (void) btnEditPressed : (id) sender ;
- (BOOL) isFormValid : (NSDictionary *) dictForm;

@end
