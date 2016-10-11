//
//  CSGGradingRubricCommentsCell.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/3/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGGradingRubricCommentsCell.h"

#import "CSGPlaceholderTextView.h"

@implementation CSGGradingRubricCommentsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor csg_gradingRailDefaultBackgroundColor];
    self.contentView.backgroundColor = [UIColor csg_gradingRailDefaultBackgroundColor];

    self.commentsTextView.placeholderText = @"Add Comment";
    
    // Style the textView to look very similar to a UITextField for consistent styling
    [self.commentsTextView.layer setBorderColor:[RGB(225, 226, 223) CGColor]];
    [self.commentsTextView.layer setBorderWidth:1.0];
    self.commentsTextView.layer.cornerRadius = 3.0f;
    self.commentsTextView.clipsToBounds = YES;
    
    self.commentsTextView.scrollEnabled = NO;
    self.commentsTextView.textContainer.widthTracksTextView = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        [self.commentsTextView becomeFirstResponder];
    } else {
        [self.commentsTextView resignFirstResponder];
    }
}

@end
