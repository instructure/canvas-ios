//
//  CSGStudentPickerCell.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/6/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGStudentPickerCell.h"

@implementation CSGStudentPickerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.scoreLabel.textColor = [UIColor csg_studentPickerStudentGradeTextColor];
    self.scoreLabel.font = [UIFont systemFontOfSize:13.0f];
    
    self.studentNameLabelWhenLate.textColor = [UIColor csg_studentPickerStudentNameTextColor];
    self.studentNameLabelWhenLate.font = [UIFont systemFontOfSize:15.0f];
    
    self.studentNameLabel.textColor = [UIColor csg_studentPickerStudentNameTextColor];
    self.studentNameLabel.font = [UIFont systemFontOfSize:15.0f];
    
    self.lateLabel.textColor = [UIColor csg_studentPickerLateTextColor];
    self.lateLabel.font = [UIFont systemFontOfSize:13.0f];
    
    self.checkmarkImageView.image = [[UIImage imageNamed:@"icon_checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.checkmarkImageView.tintColor = [UIColor csg_studentPickerTurnedInCheckColor];
}

@end
