//
//  CustomTableViewCell.m
//  TykeKnit
//
//  Created by Abhinav Singh on 30/12/10.
//  Copyright 2010 Vercingetorix Technologies. All rights reserved.
//

#import "CustomTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomTableViewCell
@synthesize content;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier1 {
	
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier1];
	if (self != nil) {
		
		CGRect tzvFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width, self.contentView.bounds.size.height+2);
		self.content = [[VXTTableCellView alloc] initWithFrame:tzvFrame];
		self.content.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.content.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview:self.content];
		[self setClipsToBounds:NO];
	}
	
	return self;
}

- (void) dealloc {
	
	[super dealloc];
}

@end
