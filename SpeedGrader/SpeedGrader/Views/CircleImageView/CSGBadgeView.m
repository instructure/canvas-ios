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

#import "CSGBadgeView.h"

@implementation CSGBadgeView

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initializeViews];
}

- (void)initializeViews {
    
    self.layer.shadowColor = [[UIColor lightGrayColor] CGColor];
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowRadius = 1.0;
    self.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    self.backgroundView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.backgroundView setContentHuggingPriority:800 forAxis:UILayoutConstraintAxisHorizontal];
    self.backgroundView.clipsToBounds = YES;
    [self addSubview:self.backgroundView];
    
    self.badgeLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.badgeLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.badgeLabel setContentHuggingPriority:800 forAxis:UILayoutConstraintAxisHorizontal];
    self.badgeLabel.textAlignment = NSTextAlignmentCenter;
    [self.backgroundView addSubview:self.badgeLabel];
    
    // Default Badge Settings
    self.borderColor = [UIColor whiteColor];
    self.borderWidth = 3.0f;
    self.backgroundView.backgroundColor = [UIColor redColor];
    
    self.badgeLabel.textColor = [UIColor whiteColor];
    self.badgeLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18.0f];
 
    [self refreshDimensions];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self refreshDimensions];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self refreshDimensions];
}

- (void)refreshDimensions {
    self.layer.cornerRadius = CGRectGetHeight(self.bounds) / 2.f;
    
    self.backgroundView.frame = CGRectInset(self.bounds, _borderWidth, _borderWidth);
    self.backgroundView.layer.cornerRadius = CGRectGetHeight(self.backgroundView.bounds) / 2.f;
}

- (void)setBorderColor:(UIColor *)borderColor {
    if (_borderColor == borderColor) {
        return;
    }
    
    _borderColor = borderColor;
    self.backgroundColor = borderColor;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (_borderWidth == borderWidth) {
        return;
    }
    
    _borderWidth = borderWidth;
}

@end
