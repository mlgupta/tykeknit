//
//  TableCellImageView.h
//  TykeKnit
//
//  Created by Abhinav Singh on 12/01/11.
//  Copyright 2011 Vercingetorix Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCellImageView : UIView {
	
	NSString *str_imageURL;
	UIView *vi_loading;
	UIImage *image;
	UIImage *defaultImage;
	
	UIImageView *theImageView;
}

@property(nonatomic, retain) UIImage *defaultImage;
@property(nonatomic, retain) UIImage *image;
@property(nonatomic, retain) NSString *str_imageURL;
- (void) setImageUrl:(NSString*)url;

@end
