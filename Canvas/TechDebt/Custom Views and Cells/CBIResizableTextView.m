//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

#import "CBIResizableTextView.h"
@import ReactiveObjC;
@import CanvasCore;


@implementation CBIResizableTextView {
    CGFloat previousHeight;
    RACSubject *viewHeightSubject;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.layer.cornerRadius = 8.f;
    self.layer.borderWidth = 1/[UIScreen mainScreen].scale;
    self.layer.borderColor = [UIColor prettyGray].CGColor;
}

- (RACSignal *)viewHeightSignal
{
    if (viewHeightSubject) {
        return viewHeightSubject;
    }
    
    return viewHeightSubject = [RACSubject subject];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat currentHeight = self.contentSize.height;
    if (currentHeight != previousHeight) {
        previousHeight = currentHeight;
        [viewHeightSubject sendNext:@(currentHeight)];

        if (self.selectedRange.location == [self.text length]) {
            [self scrollRectToVisible:CGRectMake(0, currentHeight-1, 10, 1) animated:YES];
        }
    }
}

- (void)dealloc
{
    [viewHeightSubject sendCompleted];
    viewHeightSubject = nil;
}

@end
