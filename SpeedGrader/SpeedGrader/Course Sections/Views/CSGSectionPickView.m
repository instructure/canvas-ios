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

#import "CSGSectionPickView.h"

@implementation CSGSectionPickView

+ (instancetype)instantiateFromXib {
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:self options:nil];
    CSGSectionPickView *instance = (CSGSectionPickView *)[nibViews objectAtIndex:0];
    NSAssert([instance isKindOfClass:[self class]], @"View from nib is not an instance of %@", NSStringFromClass(self));
    return instance;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    self.sectionNameLabel.textColor = [UIColor whiteColor];
}

@end
