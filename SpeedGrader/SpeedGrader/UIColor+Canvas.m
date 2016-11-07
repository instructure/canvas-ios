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

#import "UIColor+Canvas.h"

@implementation UIColor (Canvas)

- (UIColor *)colorByAdjustingBrightness:(CGFloat)adjustment
{
    CGFloat hue, saturation, brighness, alpha;
    [self getHue:&hue saturation:&saturation brightness:&brighness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:saturation brightness:(brighness + adjustment) alpha:alpha];
}

#pragma mark - Course Colors

+ (UIColor *)cbi_red
{
    return CBI_RGB(255, 56, 44);
}

+ (UIColor *)cbi_orange
{
    return CBI_RGB(252, 94, 58);
}

+ (UIColor *)cbi_gold
{
    return CBI_RGB(252, 147, 2);
}

+ (UIColor *)cbi_green
{
    return CBI_RGB(14, 209, 25);
}

+ (UIColor *)cbi_chartreuse
{
    return CBI_RGB(76, 215, 100);
}

+ (UIColor *)cbi_cyan
{
    return CBI_RGB(27, 212, 251);
}

+ (UIColor *)cbi_slate
{
    return CBI_RGB(54, 168, 218);
}

+ (UIColor *)cbi_blue
{
    return CBI_RGB(0, 122, 253);
}

+ (UIColor *)cbi_purple
{
    return CBI_RGB(88, 86, 212);
}

+ (UIColor *)cbi_violet
{
    return CBI_RGB(196, 68, 250);
}

+ (UIColor *)cbi_pink
{
    return CBI_RGB(237, 77, 180);
}

+ (UIColor *)cbi_hotPink
{
    return CBI_RGB(253, 45, 86);
}

+ (UIColor *)cbi_grey
{
    return CBI_RGB(140, 140, 144);
}

+ (UIColor *)cbi_dark_grey
{
    return CBI_RGB(85, 85, 85);
}

+ (UIColor *)cbi_black
{
    return CBI_RGB(43, 43, 43);
}

+ (UIColor *)cbi_dots
{
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"gray_dots_bg"]];
}

#pragma mark - Legacy Colors

+ (UIColor *)canvasBlack {
    return [UIColor colorWithRed:27/255.0f green:27/255.0f blue:27/255.0f alpha:1.0f];
}

+ (UIColor *)canvasGray29 {
    return [UIColor colorWithRed:29/255.0f green:29/255.0f blue:29/255.0f alpha:1.0f];
}

+ (UIColor *)canvasGray45 {
    return [UIColor colorWithRed:45/255.0f green:45/255.0f blue:45/255.0f alpha:1.0f];
}

+ (UIColor *)canvasGray59 {
    return [UIColor colorWithRed:59/255.0f green:59/255.0f blue:59/255.0f alpha:1.0f];
}

+ (UIColor *)canvasGray91 {
    return [UIColor colorWithRed:91/255.0f green:91/255.0f blue:91/255.0f alpha:1.0f];
}

+ (UIColor *)canvasGray147 {
    return [UIColor colorWithRed:147/255.0f green:147/255.0f blue:147/255.0f alpha:1.0f];
}

+ (UIColor *)canvasGray171 {
    return [UIColor colorWithRed:171/255.0f green:171/255.0f blue:171/255.0f alpha:1.0f];
}

+ (UIColor *)canvasGray203 {
    return [UIColor colorWithRed:203/255.0f green:203/255.0f blue:203/255.0f alpha:1.0f];
}

+ (UIColor *)canvasGray227 {
    return [UIColor colorWithRed:227/255.0f green:227/255.0f blue:227/255.0f alpha:1.0f];
}

+ (UIColor *)canvasGray238 {
    return [UIColor colorWithWhite:238/255.f alpha:1.0];
}

+ (UIColor *)canvasOffWhite {
    return [UIColor colorWithRed:243/255.0f green:243/255.0f blue:243/255.0f alpha:1.0f];
}

+ (UIColor *)canvasOrange {
    return [UIColor colorWithRed:242/255.0f green:86/255.0f blue:34/255.0f alpha:1.0f];
}

+ (UIColor *)canvasRed {
    return [UIColor colorWithRed:227/255.0f green:60/255.0f blue:41/255.0f alpha:1.0f];
}

+ (UIColor *)canvasGreen {
    return [UIColor colorWithRed:133/255.0f green:186/255.0f blue:19/255.0f alpha:1.0f];
}

+ (UIColor *)canvasBlue {
    return [UIColor colorWithRed:0/255.0f green:118/255.0f blue:163/255.0f alpha:1.0f];
}

+ (UIColor *)canvasTableViewHeaderGray {
    return [UIColor colorWithRed:0.90f green:0.91f blue:0.91f alpha:1.00f];
}

+ (UIColor *)canvasTintColor {
    return [UIColor colorWithRed:0.25f green:0.45f blue:0.72f alpha:1.00f];
}

@end
