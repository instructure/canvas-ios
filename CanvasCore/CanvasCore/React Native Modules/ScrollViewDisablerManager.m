//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
