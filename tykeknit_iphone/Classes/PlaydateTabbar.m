//
//  PlaydateTabbar.m
//  TykeKnit
//
//  Created by Abhinav Singh on 11/01/11.
//  Copyright 2011 Vercingetorix Technologies. All rights reserved.
//

#import "PlaydateTabbar.h"
#import "Global.h"
#import <QuartzCore/QuartzCore.h>

@implementation PlaydateTabbar
@synthesize delegate,img_selectedBtn,btn_degree,btn_gender,btn_Age;


- (id)initWithFrame:(CGRect)frame1 {
    
    self = [super initWithFrame:frame1];
    if (self) {
		
		UIImageView *imgBack = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame1.size.width, frame1.size.height+12)];
		imgBack.contentMode = UIViewContentModeScaleToFill;
		imgBack.image = [UIImage imageWithContentsOfFile:getImagePathOfName(@"tabbar_background")];
		[self addSubview:imgBack];
		[imgBack release];
		
		/*
		img_selectedBtn = [[UIImageView alloc] initWithFrame:CGRectZero];
		img_selectedBtn.contentMode = UIViewContentModeScaleToFill;
		img_selectedBtn.hidden = YES;
		img_selectedBtn.image = [UIImage imageWithContentsOfFile:VXTPathForBundleResource(@"playdate_tabBarSelected.png")];
		[self addSubview:img_selectedBtn];
		[img_selectedBtn release];
		*/
		btn_Age = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_Age addTarget:self action:@selector(ageClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn_Age setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"tabbar_age")] forState:UIControlStateNormal];
	//	[btn_Age setBackgroundColor:[UIColor yellowColor]];
		btn_Age.frame = CGRectMake(206,	10, 40, 42);
		[self addSubview:btn_Age];
		
		btn_gender = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_gender addTarget:self action:@selector(genderClicked:) forControlEvents:UIControlEventTouchUpInside];
		[btn_gender setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"tabbar_gender")] forState:UIControlStateNormal];
		btn_gender.frame = CGRectMake(28, 10, 40, 42);
		[self addSubview:btn_gender];
		
		btn_degree = [UIButton buttonWithType:UIButtonTypeCustom];
	//	[btn_degree setBackgroundColor:[UIColor redColor]];
		[btn_degree setBackgroundImage:[UIImage imageWithContentsOfFile:getImagePathOfName(@"tabbar_degree")] forState:UIControlStateNormal];
		[btn_degree addTarget:self action:@selector(degreeClicked:) forControlEvents:UIControlEventTouchUpInside];
		btn_degree.frame = CGRectMake(118, 10, 40, 42);
		[self addSubview:btn_degree];
    }
	
    return self;
}

- (void) selectionCompleted : (NSString *)name {
	if ([name isEqualToString:@"Gender"]) {
		self.btn_gender.layer.borderWidth = 0.0;
	}else if ([name isEqualToString:@"Degree"]) {
		self.btn_degree.layer.borderWidth = 0.0;
	}else if ([name isEqualToString:@"Age"]) {
		self.btn_Age.layer.borderWidth = 0.0;
	}
}

- (void) degreeClicked : (id) sender {
	self.btn_degree.layer.borderColor = [UIColor colorWithRed:0.5882 green:0.7176 blue:1.0 alpha:1.0].CGColor;
	self.btn_degree.layer.cornerRadius = 10.0;
	self.btn_degree.layer.borderWidth = 3.0;
	self.btn_Age.layer.borderWidth = 0.0;
	self.btn_gender.layer.borderWidth = 0.0;
	[self.delegate buttonSelectedOfName:@"Degree"];
}

- (void) genderClicked : (id) sender {
	
	self.btn_gender.layer.borderColor = [UIColor colorWithRed:0.5882 green:0.7176 blue:1.0 alpha:1.0].CGColor;
	self.btn_gender.layer.cornerRadius = 10.0;
	self.btn_gender.layer.borderWidth = 3.0;
	self.btn_Age.layer.borderWidth = 0.0;
	self.btn_degree.layer.borderWidth = 0.0;
	[self.delegate buttonSelectedOfName:@"Gender"];
}

- (void) ageClicked : (id) sender {
	
	self.btn_Age.layer.borderColor = [UIColor colorWithRed:0.5882 green:0.7176 blue:1.0 alpha:1.0].CGColor;
	self.btn_Age.layer.cornerRadius = 10.0;
	self.btn_Age.layer.borderWidth = 3.0;
	self.btn_gender.layer.borderWidth = 0.0;
	self.btn_degree.layer.borderWidth = 0.0;
	[self.delegate buttonSelectedOfName:@"Age"];
}

- (void)dealloc {
    [super dealloc];
}


@end
