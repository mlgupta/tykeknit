//
//  CustomSegmentView.h
//  TykeKnit
//
//  Created by Abhinav Singh on 14/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomSegmentView;

@protocol CustomSegmentViewDelegate <NSObject>

@optional

- (void) segementIndexChanged : (CustomSegmentView*) sender callAPI:(BOOL)callAPI;
@end


@interface CustomSegmentView : UIView {

	NSMutableArray *arr_data;
	UIImageView *back_imageView;
	int selectedIndex;
	NSString *defaultimage;
	id <CustomSegmentViewDelegate>delegate;
	BOOL callAPI;
}

@property(nonatomic, assign) int selectedIndex;
@property(nonatomic, assign) id <CustomSegmentViewDelegate>delegate;
@property(nonatomic, assign) NSString *defaultimage;

- (id)initWithFrame:(CGRect)frame withSegments:(NSMutableArray*)segments defaultImage:(NSString *)defaultImage andDelegate:(id)listner;


@end
