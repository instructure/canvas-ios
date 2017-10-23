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
    
    

#import "MKNumberBadgeView+CanvasStyle.h"

#import "UIFont+Canvas.h"

@implementation MKNumberBadgeView (CanvasStyle)

+ (instancetype)badgeViewForView:(UIView *)view
{
    MKNumberBadgeView *badgeView = [[MKNumberBadgeView alloc] initWithFrame:CGRectMake(0, -10, view.bounds.size.width+6, 24)];
    badgeView.pad = 0;
    badgeView.shadow = NO;
    badgeView.shine = NO;
    badgeView.shadowOffset = CGSizeMake(0, 2);
    badgeView.font = [UIFont canvasFontOfSize:12];
    badgeView.alignment = NSTextAlignmentRight;
    badgeView.userInteractionEnabled = NO;
    badgeView.hideWhenZero = YES;
// MKNumberBadgeView should be removed with `remove-old-inbox` see https://github.com/instructure/ios/pull/1123
//    badgeView.fillColor = Brand.current.tintColor;
//    badgeView.strokeColor = Brand.current.tintColor;
    badgeView.strokeWidth = 0;
    return badgeView;
}

@end
