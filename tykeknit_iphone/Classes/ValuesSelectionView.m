//
//  ValuesSelectionView.m
//  TykeKnit
//
//  Created by Abhinav Singh on 02/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "ValuesSelectionView.h"

@implementation ValuesSelectionView
@synthesize arr_values, theScrollView, targetController, str_typeOfSelection;

- (id)initWithFrame:(CGRect)frame Values:(NSMutableArray*)arrValue Style:(SelectionStyle)sel_style{
	
    if ((self = [super initWithFrame:frame])) {
		
		self.backgroundColor = [UIColor clearColor];
		
		UIImageView *imgPoint = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 35, 20)];
		imgPoint.tag = 123;
		imgPoint.contentMode = UIViewContentModeScaleToFill;
		imgPoint.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pointRandomButtons" ofType:@"png"]];
		[self addSubview:imgPoint];
		[imgPoint release];
		
		UIImageView *imgBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		imgBack.contentMode = UIViewContentModeScaleToFill;
		imgBack.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"randomButtonsBack" ofType:@"png"]];
		[self addSubview:imgBack];
		[imgBack release];
		
		style = sel_style;
		self.arr_values = arrValue;
		
		self.theScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 2.5, frame.size.width-20, 25)];
		self.theScrollView.backgroundColor = [UIColor clearColor];
		
		self.theScrollView.showsHorizontalScrollIndicator = NO;
		[self addSubview:theScrollView];
		
		float xAxcis = 10;
		CGSize aSize;
		
		for (int i = 0; i < [self.arr_values count]; i++) {
			
			NSDictionary *dict = [self.arr_values objectAtIndex:i];
			NSString *strTitle = [dict objectForKey:@"value"];
			aSize = [strTitle sizeWithFont:[UIFont boldSystemFontOfSize:12] constrainedToSize:CGSizeMake(FLT_MAX, FLT_MAX) lineBreakMode:UILineBreakModeWordWrap];
			
			UIButton *btn_value = [UIButton buttonWithType:UIButtonTypeCustom];
			
			[btn_value setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] 
																			pathForResource:@"selectedRandomButton" ofType:@"png"]] forState:UIControlStateHighlighted];
			
			if ([[dict objectForKey:@"selected"] intValue]) {
				[btn_value setBackgroundImage:[UIImage imageWithContentsOfFile:[[NSBundle mainBundle] 
																				pathForResource:@"selectedRandomButton" ofType:@"png"]] forState:UIControlStateNormal];
			}
			
			[btn_value setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			btn_value.tag = i+100;
			btn_value.frame = CGRectMake( xAxcis, 2.5, aSize.width+20, 20);
			btn_value.backgroundColor = [UIColor clearColor];
			[[btn_value titleLabel] setFont:[UIFont boldSystemFontOfSize:10]];
			[btn_value addTarget:self action:@selector(donePressed:) forControlEvents:UIControlEventTouchUpInside];
			
			[btn_value setTitle:strTitle forState:UIControlStateNormal];
			[self.theScrollView addSubview:btn_value];
			xAxcis += aSize.width + 30;
		}
		
		[self.theScrollView setContentSize:CGSizeMake(xAxcis, 20)];
		if (self.frame.size.width > xAxcis+20) {
			
			CGRect oldRect = self.frame;
//			oldRect.origin.x += oldRect.size.width - xAxcis;
			oldRect.size.width = xAxcis+20;
			self.frame = oldRect;
			
			imgBack.frame = CGRectMake(0, 0, oldRect.size.width, oldRect.size.height);
			self.theScrollView.frame = CGRectMake(10, 2.5, xAxcis, 20);
		}
    }
	
    return self;
}

- (void) showPointAtLocation : (CGPoint)pt{
	
	[[self viewWithTag:123] setFrame:CGRectMake(pt.x, pt.y, 35, 20)];
}

- (void) selectionCompleted {
	
	if([self.targetController respondsToSelector:@selector(valuesSelectionCompleted:TypeOf:)]){
//		[self.targetController valuesSelectionCompleted:self.arr_values TypeOf:self.str_typeOfSelection];// valuesSelectionCompleted:self.arr_values TypeOf:self.str_typeOfSelection];
	}
	
	[self removeFromSuperview];
}

- (void) donePressed : (id) sender {
	
	UIButton *btn_current = (UIButton*)sender;
	int tagIndex = btn_current.tag;
	NSMutableDictionary *dictData = [self.arr_values objectAtIndex:tagIndex-100];
	
	if (style == SelectionStyleSingle) {
		for (NSMutableDictionary *dict in self.arr_values) {
			[dict setObject:@"0" forKey:@"selected"];
		}
		
		[dictData setObject:@"1" forKey:@"selected"];
		[self selectionCompleted];
	}else if(style == SelectionStyleMultiple) {
		
		if ([[dictData objectForKey:@"selected"] intValue]) {
			[dictData setObject:@"0" forKey:@"selected"];
		}else {
			[dictData setObject:@"1" forKey:@"selected"];
		}
	}
}

#pragma mark -
#pragma mark UITableViewDelagate Methods

- (void)dealloc {
	
	[self.theScrollView release];
    [super dealloc];
}

@end
