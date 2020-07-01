//
//  UIPlaceHolderTextView.h
//  TykeKnit
//
//  Created by Manish Gupta on 25/06/11.
//  Copyright 2011 Tykeknit. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIPlaceHolderTextView : UITextView {
    
    NSString *_placeholder;
    UIColor *_placeholderColor;
    
    BOOL _shouldDrawPlaceholder;
}

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

@end

