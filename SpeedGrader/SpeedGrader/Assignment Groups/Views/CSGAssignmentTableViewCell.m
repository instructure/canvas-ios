//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
