
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
    
    

#import "CBISplitTransitionShadowView.h"

@implementation CBISplitTransitionShadowView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        CAGradientLayer *layer = (CAGradientLayer *)self.layer;
        layer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[UIColor colorWithWhite:0 alpha:0.20].CGColor];
        layer.startPoint = CGPointMake(0., 0.5);
        layer.endPoint = CGPointMake(1., 0.5);

    }
    return self;
}

@end
