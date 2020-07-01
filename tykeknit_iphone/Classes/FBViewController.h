//
//  FBViewController.h
//  TykeKnit
//
//  Created by Abhinit Tiwari on 22/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceBookEngine.h"


@interface FBViewController : UIViewController<FaceBookEngineDelegate> {	
	FaceBookEngine *objFaceBook;
	NSMutableDictionary *dictUserInfo;
}

@property(nonatomic, retain) NSMutableDictionary *dictUserInfo;

@end
