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

#define CBI_RGB(r, g, b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]

@interface UIColor (Canvas)

- (UIColor *)colorByAdjustingBrightness:(CGFloat)adjustment;

+ (UIColor *)cbi_red;
+ (UIColor *)cbi_orange;
+ (UIColor *)cbi_gold;
+ (UIColor *)cbi_green;
+ (UIColor *)cbi_chartreuse;
+ (UIColor *)cbi_cyan;
+ (UIColor *)cbi_slate;
+ (UIColor *)cbi_blue;
+ (UIColor *)cbi_purple;
+ (UIColor *)cbi_violet;
+ (UIColor *)cbi_pink;
+ (UIColor *)cbi_hotPink;
+ (UIColor *)cbi_grey;
+ (UIColor *)cbi_dark_grey;
+ (UIColor *)cbi_black;
+ (UIColor *)cbi_dots;

#pragma mark - Legacy Colors
+ (UIColor *)canvasBlack;
+ (UIColor *)canvasGray29;
+ (UIColor *)canvasGray45;
+ (UIColor *)canvasGray59;
+ (UIColor *)canvasGray91;
+ (UIColor *)canvasGray147;
+ (UIColor *)canvasGray171;
+ (UIColor *)canvasGray203;
+ (UIColor *)canvasGray227;
+ (UIColor *)canvasGray238;
+ (UIColor *)canvasOffWhite; // gray243
+ (UIColor *)canvasOrange;
+ (UIColor *)canvasRed;
+ (UIColor *)canvasGreen;
+ (UIColor *)canvasBlue;
+ (UIColor *)canvasTableViewHeaderGray;
+ (UIColor *)canvasTintColor;

@end
