//
//  CBIRichTextInputView.m
//  iCanvas
//
//  Created by derrick on 2/11/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBISubmissionInputView.h"

@implementation CBISubmissionInputView

- (void)loadNib
{
    self.placeholderText = NSLocalizedString(@"Enter submission",@"Submission input view placeholder text");
}

@end
