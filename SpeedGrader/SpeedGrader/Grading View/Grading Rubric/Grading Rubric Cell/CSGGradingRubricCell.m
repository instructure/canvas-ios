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
