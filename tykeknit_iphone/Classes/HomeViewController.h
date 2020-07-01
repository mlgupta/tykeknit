//
//  HomeViewController.h
//  TykeKnit
//
//  Created by Abhinav Singh on 07/02/11.
//  Copyright 2011 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController {

	UIBarButtonItem *back;
	UINavigationItem *titleHome;
}
@property(nonatomic,retain) IBOutlet UINavigationItem *titleHome;
@property(nonatomic,retain) IBOutlet UIBarButtonItem *back;

- (void) removeView : (UIView *) vi;
- (void) playDateClicked : (id) sender;
- (void) settingsClicked : (id) sender;
- (void) dashBoardClicked : (id) sender;
- (void) eventsClicked : (id) sender;
- (void) cancelClicked: (id) sender ;
@end