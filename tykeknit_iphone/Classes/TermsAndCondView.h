//
//  TermsAndCondView.h
//  TykeKnit
//
//  Created by Abhinit Tiwari on 07/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TermsAndCondView : UIViewController {

	UIScrollView *objScrollView;
	
}
@property(nonatomic, retain) IBOutlet UIScrollView *objScrollView;

- (void) funBackButtonClicked : (id) sender;
@end
