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
    
    

#import "CBISplitSeparatorView.h"
@import SoPretty;


@interface CBISplitSeparatorView ()
@property (nonatomic) CALayer *separatorLayer;
@end

@implementation CBISplitSeparatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor clearColor];
        self.color = [UIColor prettyGray];
        _separatorLayer = [CALayer layer];
        [self.layer addSublayer:_separatorLayer];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGRect frame = self.bounds;
    CGFloat lineWidth = 1/[UIScreen mainScreen].scale;
    frame.origin.x = frame.size.width - lineWidth;
    frame.size.width = lineWidth;
    self.separatorLayer.frame = frame;
    self.separatorLayer.backgroundColor = self.color.CGColor;
    [CATransaction commit];
}

@end
