//
//  MultiLineTextField.h
//  iCanvas
//
//  Created by BJ Homer on 10/12/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NonResponsiveTextField.h"

@interface MultiLineTextField : NonResponsiveTextField

@property (weak, nonatomic) id <UITextViewDelegate> textViewDelegate;
@property (copy, nonatomic) NSString *text;


@property (strong, readonly) UITextView *textView;

@property int minimumLineCount;
@property int maximumLineCount;

- (CGSize) fittingSizeForText:(NSString *)string;
@end
