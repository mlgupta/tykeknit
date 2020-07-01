//
//  CalenderView.m
//  TykeKnit
//
//  Created by Ver on 08/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CalenderView.h"


@implementation CalenderView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.

    }
    return self;
}

/*
- (UIView *) initWithImageName:(NSString *)imageName date:(NSDate *)date {
	
	UILabel *lbl_month = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, self.frame.size.width - 5, 20);
	[self addSubview:lbl_month];
	[lbl_month release];
}
*/
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

					  
- (void)dealloc {
    [super dealloc];
}


@end
