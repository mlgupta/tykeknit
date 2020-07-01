//  CustomSegmentView.m
//  TykeKnit
//
//  Created by Abhinav Singh on 14/03/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "CustomSegmentView.h"

@implementation CustomSegmentView
@synthesize selectedIndex, delegate,defaultimage;


- (id)initWithFrame:(CGRect)frame withSegments:(NSMutableArray*)segments defaultImage:(NSString *)defaultImage andDelegate:(id)listner{
    
    self = [super initWithFrame:frame];
    if (self) {
		
		self.backgroundColor = [UIColor colorWithRed:0.929 green:0.949 blue:0.961 alpha:1.0];
		
		self.delegate = listner;
		back_imageView = [[UIImageView alloc] initWithFrame:CGRectMake( 0, 0, frame.size.width, frame.size.height)];
		back_imageView.tag = 350;
		back_imageView.contentMode = UIViewContentModeScaleToFill;
		arr_data = [segments retain];
		
		[self addSubview:back_imageView];
		[back_imageView release];
		selectedIndex = -1100;
		int i = 1;
		float xAxics = 0;
		float forEach = (frame.size.width/[arr_data count]);

		self.defaultimage = [defaultImage retain];
		
		for (NSDictionary *dict in segments) {
			
			UIButton *btn_index = [UIButton buttonWithType:UIButtonTypeCustom];
			btn_index.frame = CGRectMake(xAxics, 0, forEach, frame.size.height);
			btn_index.tag = i;
			[btn_index setTitle:[dict objectForKey:@"title"] forState:UIControlStateNormal];
			[btn_index setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
			[btn_index addTarget:self action:@selector(segmentClicked:) forControlEvents:UIControlEventTouchUpInside];
			[btn_index titleLabel].layer.shadowOffset = CGSizeMake(0, -1);
			[btn_index titleLabel].layer.shadowRadius = 1.0;
			[btn_index titleLabel].layer.shadowColor = [UIColor blackColor].CGColor;
			[[btn_index titleLabel] setFont:[UIFont boldSystemFontOfSize:13]];
			[[btn_index titleLabel] setShadowColor:[UIColor blackColor]];
			[self addSubview:btn_index];
			
			xAxics += forEach;
			i++;
		}
		if ([self.defaultimage length]) {
			self.selectedIndex = -1;
		}else {
			self.selectedIndex = 1;
		}

		
    }
	
    return self;
}

- (void) setSelectedIndex : (int)selected {
	
	if (self.selectedIndex != selected) {
		
		UIButton *btn_prev = (UIButton*)[self viewWithTag:self.selectedIndex];
		UIButton *btn_new = (UIButton*)[self viewWithTag:selected];

		if (btn_new) {
			if (btn_prev) {
				[btn_prev setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
			}
			
			[btn_new setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal] ;
			
			back_imageView.image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] 
																	 stringByAppendingPathComponent:[[arr_data objectAtIndex:(btn_new.tag-1)] objectForKey:@"imageName"]]];
			
			selectedIndex = selected;
			
			if ([self.delegate respondsToSelector:@selector(segementIndexChanged:callAPI:)]) {
				[self.delegate segementIndexChanged:self callAPI:callAPI];
			}
		}else {
			UIImage *img =  [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] 
															  stringByAppendingPathComponent:self.defaultimage]];
			if (img) {
				back_imageView.image = [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] 
																		 stringByAppendingPathComponent:self.defaultimage]];
			}else {
				[back_imageView setBackgroundColor:[UIColor clearColor]];
			}

			selectedIndex = selected;
			
//			back_imageView.image = 
		}

	}
}

- (void) segmentClicked : (id) sender {
	
	callAPI = YES;
	self.selectedIndex = [(UIButton*)sender tag];
	callAPI = NO;
}

- (void)dealloc {
	
	[arr_data release];
    [super dealloc];
}


@end
