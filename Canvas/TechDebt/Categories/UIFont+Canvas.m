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
    
    

#import "UIFont+Canvas.h"

@implementation UIFont (Canvas)

#pragma mark - Font Generators

+ (UIFont *)canvasFontOfSize:(CGFloat)size {
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)boldCanvasFontOfSize:(CGFloat)size {
    return [UIFont boldSystemFontOfSize:size];
}

+ (UIFont *)italicCanvasFontOfSize:(CGFloat)size {
    return [UIFont italicSystemFontOfSize:size];
}

#pragma mark - Predefined Fonts

+ (UIFont *)canvasHeaderFont {
    return [UIFont canvasFontOfSize:18.0f];
}

+ (UIFont *)canvasHeader2Font {
    return [UIFont canvasFontOfSize:13.0f];
}

+ (UIFont *)canvasHeader2BoldFont {
    return [UIFont boldCanvasFontOfSize:13.0f];
}

+ (UIFont *)canvasSubHeaderFont {
    return [UIFont boldCanvasFontOfSize:11.0f];
}

+ (UIFont *)canvasFont {
    return [UIFont canvasFontOfSize:11.0f];
}

+ (UIFont *)canvasSmallFont {
    return [UIFont canvasFontOfSize:9.0f];
}

@end
