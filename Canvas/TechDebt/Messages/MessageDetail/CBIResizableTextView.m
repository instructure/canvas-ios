//
//  CBIResizableTextView.m
//  iCanvas
//
//  Created by derrick on 12/2/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIResizableTextView.h"
@import ReactiveCocoa;
@import SoPretty;


@implementation CBIResizableTextView {
    CGFloat previousHeight;
    RACSubject *viewHeightSubject;
}

- (void)awakeFromNib
{
    self.layer.cornerRadius = 8.f;
    self.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    self.layer.borderColor = [UIColor prettyGray].CGColor;
}

- (RACSignal *)viewHeightSignal
{
    if (viewHeightSubject) {
        return viewHeightSubject;
    }
    
    return viewHeightSubject = [RACSubject subject];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat currentHeight = self.contentSize.height;
    if (currentHeight != previousHeight) {
        previousHeight = currentHeight;
        [viewHeightSubject sendNext:@(currentHeight)];

        if (self.selectedRange.location == [self.text length]) {
            [self scrollRectToVisible:CGRectMake(0, currentHeight-1, 10, 1) animated:YES];
        }
    }
}

- (void)dealloc
{
    [viewHeightSubject sendCompleted];
    viewHeightSubject = nil;
}

@end
