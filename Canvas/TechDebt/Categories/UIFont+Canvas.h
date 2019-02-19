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
    
    

#import <UIKit/UIKit.h>

@interface UIFont (Canvas)

#pragma mark - Font Generators
+ (UIFont *)canvasFontOfSize:(CGFloat)size;
+ (UIFont *)boldCanvasFontOfSize:(CGFloat)size;
+ (UIFont *)italicCanvasFontOfSize:(CGFloat)size;

#pragma mark - Predefined Fonts
+ (UIFont *)canvasHeaderFont; // 18pt regular
+ (UIFont *)canvasHeader2Font; // 13pt regular
+ (UIFont *)canvasHeader2BoldFont; // 13pt bold
+ (UIFont *)canvasSubHeaderFont; // 11pt bold;
+ (UIFont *)canvasFont; // 11 regular
+ (UIFont *)canvasSmallFont; // 9pt regular
@end
