//
//  MultiLineTextField.m
//  iCanvas
//
//  Created by BJ Homer on 10/12/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import "MultiLineTextField.h"
#import <QuartzCore/QuartzCore.h>


@implementation MultiLineTextField {
    UITextView *textView;
}
@synthesize textViewDelegate;
@synthesize textView;
@synthesize minimumLineCount;
@synthesize maximumLineCount;

- (BOOL)isAccessibilityElement {
    return NO;
}


- (NSInteger)accessibilityElementCount {
    return 1;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    return textView;
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    return 0;
}

- (void)awakeFromNib {
    self.clipsToBounds = YES;
    
    CGRect textViewFrame = self.bounds;
    textViewFrame.size.height -= 6;
    
    textView = [[UITextView alloc] initWithFrame:textViewFrame];
    textView.backgroundColor = [UIColor clearColor];
    textView.clipsToBounds = NO;
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    textView.delegate = self->textViewDelegate;
    textView.font = [UIFont systemFontOfSize:13];
    textView.contentMode = UIViewContentModeTop;
    
    self.minimumLineCount = 3;
    self.maximumLineCount = 10;
    
    [self addSubview:textView];
    
    textView.isAccessibilityElement = YES;
}

- (void)setTextViewDelegate:(id<UITextViewDelegate>)aTextViewDelegate {
    textView.delegate = aTextViewDelegate;
}



- (void)setText:(NSString *)theText {
    textView.text = theText;
}

- (NSString *)text {
    return textView.text;
}


- (CGSize)fittingSizeForLineCount:(int)x {
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"a" attributes:@{NSFontAttributeName: self.textView.font}];
    for (int i=0; i<x-1; ++i) {
        [str appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@"\na" attributes:@{NSFontAttributeName: self.textView.font}]];
    }
    
    CGRect rect = [str boundingRectWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return rect.size;
}

- (CGSize)fittingSizeForText:(NSString *)string {
    
    CGSize minimumSize = [self fittingSizeForLineCount:self.minimumLineCount];
    CGSize maximumSize = [self fittingSizeForLineCount:self.maximumLineCount];
    
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: self.textView.font}];
    CGRect rect = [attributedString boundingRectWithSize:CGSizeMake(textView.bounds.size.width, maximumSize.height) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    CGSize fittingSize = CGSizeMake(rect.size.width, rect.size.height);
    
    if (fittingSize.height < minimumSize.height) {
        fittingSize.height = minimumSize.height;
    }
    fittingSize.height += 6; // Make room for the surrounding bezel
    fittingSize.width = textView.bounds.size.width;
    
    return fittingSize;
}


@end
