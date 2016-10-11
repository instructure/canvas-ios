//
//  CSGGradingRubricCell.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 9/3/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGGradingRubricCell.h"

@implementation CSGGradingRubricCell

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
    
    self.rubricDescriptionLabel.font = [UIFont systemFontOfSize:14.0f];
 
    self.pointsBadge.font = [UIFont systemFontOfSize:14.0f];
    self.pointsBadge.layer.cornerRadius = CGRectGetHeight(self.pointsBadge.frame)/2;
    self.pointsBadge.clipsToBounds = YES;
    self.pointsBadge.textAlignment = NSTextAlignmentCenter;
    
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
    selectedBackgroundView.backgroundColor = [UIColor csg_gradingRailDefaultBackgroundColor];
    self.selectedBackgroundView = selectedBackgroundView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
