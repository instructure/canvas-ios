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

#import "CSGNoResultsView.h"

@implementation CSGNoResultsView

+ (instancetype)instantiateFromXib {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil];
    CSGNoResultsView *instance = (CSGNoResultsView *)[nibViews objectAtIndex:0];
    NSAssert([instance isKindOfClass:[self class]], @"View from nib is not an instance of %@", NSStringFromClass(self));
    return instance;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.containerView.backgroundColor = [UIColor clearColor];
    
    self.commentLabel.backgroundColor = [UIColor clearColor];
    self.commentLabel.font = [UIFont systemFontOfSize:24.0f];
    self.commentLabel.textColor = self.tintColor;
    
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.tintColor = self.tintColor;
    
    self.tintColor = [UIColor lightGrayColor];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    
    self.commentLabel.textColor = self.tintColor;
    self.imageView.tintColor = self.tintColor;
}

@end
