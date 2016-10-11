//
//  MultiLineTextViewTableViewCell.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 11/6/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "MultiLineTextViewTableViewCell.h"

@interface MultiLineTextViewTableViewCell () <UITextViewDelegate>


@end

@implementation MultiLineTextViewTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    self.textView.scrollEnabled = NO;
    self.textView.delegate = self;
    
    self.textView.textContainer.widthTracksTextView = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        [self.textView becomeFirstResponder];
    } else {
        [self.textView resignFirstResponder];
    }
}

@end
