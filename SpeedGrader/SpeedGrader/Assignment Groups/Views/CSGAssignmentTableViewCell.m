//
//  CSGAssignmentTableViewCell.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 10/3/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGAssignmentTableViewCell.h"

#import "CSGBadgeView.h"

@implementation CSGAssignmentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // Initialization code
    
    self.contentView.backgroundColor = [UIColor csg_offWhite];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setAssignment:(CKIAssignment *)assignment {
    _assignment = assignment;
    
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM d, yyyy hh:mma"];
    }
    self.dueDateLabel.text = [dateFormatter stringFromDate:assignment.dueAt];
    
    self.nameLabel.text = assignment.name;
    self.iconImageView.image = [self iconForAssignment:assignment];
    self.iconImageView.tintColor = self.tintColor;
    
    if (assignment.dueAt) {
        self.nameLabelCenterConstraint.constant = 8;
    } else {
        self.nameLabelCenterConstraint.constant = 0;
    }
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
}

- (UIImage *)iconForAssignment:(CKIAssignment *)assignment {
    NSArray *submissionTypes = assignment.submissionTypes;
    NSString *imageName = nil;
    
    if ([submissionTypes containsObject:@"discussion_topic"]) {
        imageName = @"icon_discussions";
    }
    else if ([submissionTypes containsObject:@"online_quiz"]) {
        imageName = @"icon_quizzes";
    }
    else {
        imageName = @"icon_assignments";
    }
    
    return [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setNeedsGradingCountForSection:(NSString *)sectionId {

    NSInteger needsGradingCount = self.assignment.needsGradingCount;

    // if a section is selected
    if (sectionId) {
        // Default to zero for the section
        needsGradingCount = 0;
        
        NSNumber *needsGradingCountBySection = [self.assignment.needsGradingCountBySection objectForKey:sectionId];
        // if there was actually a count for the selected section change the count used to make the view
        if (needsGradingCountBySection != nil) {
            needsGradingCount = [needsGradingCountBySection integerValue];
        }
    }
    
    if (needsGradingCount == 0) {
        self.needsGradingBadgeView.hidden = YES;
        return;
    }
    
    static NSNumberFormatter *formatter;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
    });
    
    NSString *needsGradingCountText = [NSString stringWithFormat:@"%ld", (long)needsGradingCount];
    self.needsGradingBadgeView.badgeLabel.text = needsGradingCountText;
    self.needsGradingBadgeView.hidden = NO;
}

@end
