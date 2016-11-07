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
