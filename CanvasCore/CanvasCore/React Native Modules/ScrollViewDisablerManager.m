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

#import "ScrollViewDisablerManager.h"
#import <React/RCTBridge.h>
#import <React/RCTView.h>

@interface ScrollViewDisabler : RCTView
@end

@implementation ScrollViewDisablerManager

RCT_EXPORT_MODULE()

- (UIView *)view {
    return [[ScrollViewDisabler alloc] init];
}

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

@end

@implementation ScrollViewDisabler

- (void)layoutSubviews {
    [super layoutSubviews];
    [self disableScrolling:self];
}

- (void)disableScrolling:(UIView *)parent {
    for (UIView *view in parent.subviews) {
        UIScrollView *scrollView = (UIScrollView *)view;
        if ([scrollView isKindOfClass:[UIScrollView class]]) {
            scrollView.scrollEnabled = NO;
        }
        [self disableScrolling:view];
    }
}

@end
