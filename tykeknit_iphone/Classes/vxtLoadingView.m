//
//  vxtLoadingView.m
//  LiveTappApp
//
//  Created by Abhinav Singh @ Vercingetorix Technologies on 23/04/10.
//  Copyright 2010 Krupa Ventures, Inc. All Rights Reserved.
//

#import "vxtLoadingView.h"

@implementation vxtLoadingView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		int yAxics = frame.size.height/2 - 30;
		
		UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		indicator.tag = 1020;
		CGRect rect = indicator.frame;
		
		rect.origin.x = 105;
		rect.origin.y = yAxics;
		indicator.frame = rect;
		[indicator startAnimating];
		[self addSubview:indicator];
		[indicator release];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(130, yAxics-12, 80, 45)];
		label.text = @"Loading";
		label.font = [UIFont boldSystemFontOfSize:20];
		label.textColor = [UIColor whiteColor];
		label.backgroundColor = [UIColor clearColor];
		
		label.textAlignment = UITextAlignmentCenter;
		[self addSubview:label];
		[label release];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}


@end
