//
//  ValuesSelectionView.h
//  TykeKnit
//
//  Created by Abhinav Singh on 02/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	
	SelectionStyleSingle,
	SelectionStyleMultiple,
}SelectionStyle;

@interface ValuesSelectionView : UIView {
	
	NSMutableArray *arr_values;
	UIScrollView *theScrollView;
	SelectionStyle style;
	id targetController;
	NSString *str_typeOfSelection;
}

@property (nonatomic, retain) NSString *str_typeOfSelection;
@property (nonatomic, assign) id targetController;
@property (nonatomic, retain) UIScrollView *theScrollView;
@property (nonatomic, retain) NSMutableArray *arr_values;

- (void) showPointAtLocation : (CGPoint)pt;
- (id) initWithFrame:(CGRect)frame Values:(NSMutableArray*)arrValue Style:(SelectionStyle)sel_style;

@end
