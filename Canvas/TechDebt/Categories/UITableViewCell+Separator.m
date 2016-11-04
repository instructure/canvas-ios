
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
    
    

#import "UITableViewCell+Separator.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

@implementation UITableViewCell (Separator)
static const void *separatorLineColorPropertyKey = &separatorLineColorPropertyKey;
- (UIColor *)separatorLineColor {
    return objc_getAssociatedObject(self, separatorLineColorPropertyKey);
}

- (void)setSeparatorLineColor:(UIColor *)color {
    objc_setAssociatedObject(self, separatorLineColorPropertyKey, color, OBJC_ASSOCIATION_RETAIN);
    
    UIView *backgroundView = self.backgroundView;
    if (!backgroundView) {
        backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = self.backgroundColor;
    }
    
    [self.viewForBaselineLayout layoutIfNeeded];
    
    static CGFloat SeparatorHeight = 1.0f;
    CGRect separatorRect, contentRect;
    CGRect frame = self.contentView.frame;
    CGRectDivide(frame, &separatorRect, &contentRect, SeparatorHeight, CGRectMaxYEdge);
    
    UIView *separatorView = [[UIView alloc] initWithFrame:separatorRect];
    separatorView.backgroundColor = color;
    [backgroundView addSubview:separatorView];
    self.backgroundView = backgroundView;
}
@end
