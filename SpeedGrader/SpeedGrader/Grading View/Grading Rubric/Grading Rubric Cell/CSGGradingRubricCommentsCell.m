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
