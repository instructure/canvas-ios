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

//
// UIColor+CSGColor.m
// Created by Jason Larsen on 5/13/14.
//

#import "UIColor+CSGColor.h"

#import "UIImage+ColorAtPixel.h"
#import "UIImage+Color.h"
#import "CSGAppDataSource.h"

#define HEX(r) \
[UIColor colorWithHex:(r)]

@implementation UIColor (CSGColor)

+ (UIColor *)colorWithHex:(UInt32)col
{
    unsigned char r, g, b;
    b = col & 0xFF;
    g = (col >> 8) & 0xFF;
    r = (col >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:1];
}

+ (UIColor *)csg_highlightColor
{
    return [CSGUserPrefsKeys secondaryColorForCourseID:[CSGAppDataSource sharedInstance].course.id];
}

#pragma mark - Settings Colors
+ (UIColor *)csg_settingsLightBlue;
{
    return RGB(85, 192, 214);
}

+ (UIColor *)csg_settingsTextColor
{
    return RGB(255, 255, 255);
}

+ (UIColor *)csg_settingsAvatarBorderColor
{
    return [UIColor csg_settingsTextColor];
}

+ (UIColor *)csg_settingsLightGreyTextColor
{
    return RGB(174, 183, 198);
}

+ (UIColor *)csg_settingsDarkGreyTextColor
{
    return RGB(79, 79, 81);
}

+ (UIColor *)csg_settingsSwitchOnColor
{
    return RGB(25, 188, 189);
}

+ (UIColor *)csg_settingsSwitchOffColor
{
    return RGB(176, 185, 200);
}

+ (UIColor *)csg_settingsBackgroundColor
{
    return RGB(248, 249, 246);
}

+ (UIColor *)csg_settingsLogoutButtonColor
{
    return [UIColor csg_settingsLightBlue];
}

+ (UIColor *)csg_settingsLogoutButtonTintColor
{
    return [UIColor csg_settingsTextColor];
}

+ (UIColor *)csg_settingsContainerBackgroundColor
{
    return RGB(255,255,255);
}

+ (UIColor *)csg_settingsContainerBorderColor
{
    return RGB(243, 244, 242);
}

#pragma mark - Section Picker Colors

+ (UIColor *)csg_sectionPickerBackgroundColor
{
    return RGB(255, 255, 255);
}

#pragma mark - StudentPicker Colors
+ (UIColor *)csg_studentPopoverBackgroundColor {
    return RGB(109, 200, 219);
}
+ (UIColor *)csg_studentPickerBackgroundColor {
    return [UIColor csg_settingsLightBlue];
}

+ (UIColor *)csg_studentPickerHeaderBackgroundColor {
    return [UIColor csg_settingsLightBlue];
}

+ (UIColor *)csg_studentPickerHeaderTintColor {
    return RGB(255, 255, 255);
}

+ (UIColor *)csg_studentPickerFooterBackgroundColor {
    return [UIColor csg_settingsLightBlue];
}

+ (UIColor *)csg_studentPickerFooterTextColor {
    return RGB(255, 255, 255);
}

+ (UIColor *)csg_studentPickerCheckmarkColor {
    return RGB(61, 180, 76);
}

+ (UIColor *)csg_studentPickerStudentCellBackgroundColor {
    return RGB(255, 255, 255);
}

+ (UIColor *)csg_studentPickerStudentNameTextColor {
    return RGB(48, 48, 50);
}

+ (UIColor *)csg_studentPickerLateTextColor {
    return RGB(236, 69, 70);
}

+ (UIColor *)csg_studentPickerTurnedInCheckColor {
    return RGB(61, 175, 75);
}

+ (UIColor *)csg_studentPickerStudentGradeTextColor {
    return RGB(125, 126, 129);
}

#pragma mark - Navigation Bar Color

+ (UIColor *)csg_defaultNavigationBarColor {
    return RGB(20, 78, 115);
}

+ (UIColor *)csg_defaultGradingRailGrey {
    return RGB(190, 190, 185);
}

#pragma mark - Grading Rail Colors
+ (UIColor *)csg_gradingRailHeaderBackgroundColor
{
    return [UIColor csg_defaultGradingRailGrey];
}

+ (UIColor *)csg_gradingRailAssignmentNameTextColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)csg_gradingRailLightSegmentControlColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)csg_gradingRailDarkSegmentControlColor
{
    return [UIColor csg_defaultGradingRailGrey];
}

+ (UIColor *)csg_gradingRailRubricSectionViewBackgroundColor
{
    return [UIColor csg_defaultGradingRailGrey];
}

+ (UIColor *)csg_gradingRailRubricSectionViewTextColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)csg_gradingRailRubricCriterionTitleTextColor
{
    return RGB(67, 66, 67);
}

+ (UIColor *)csg_gradingRailRubricCriterionPointsTextColor
{
    return RGB(167, 177, 193);
}

+ (UIColor *)csg_gradingRailDefaultBackgroundColor
{
    return RGB(248, 249, 246);
}

+ (UIColor *)csg_gradingPickerBackgroundColor {
    return [UIColor csg_gradingRailDefaultBackgroundColor];
}

+ (UIColor *)csg_gradingRailSubmitGradeButtonBackgroundColor
{
    return [UIColor csg_highlightColor];
}

+ (UIColor *)csg_gradingRailSubmitGradeDisabledButtonBackgroundColor
{
    return [UIColor csg_defaultGradingRailGrey];
}

+ (UIColor *)csg_gradingRailSubmitGradeButtonTextColor
{
    return RGB(255, 255, 255);
}

+ (UIColor *)csg_gradingRailSubmitGradeDisabledButtonTextColor
{
    return RGB(255, 255, 255);
}

+ (UIColor *)csg_gradingRailGradeContextLabelTextColor
{
    return RGB(150, 150, 150);
}

+ (UIColor *)csg_gradingRailStatusColorDefault
{
    return [UIColor csg_highlightColor];
}

+ (UIColor *)csg_gradingRailStatusColorSuccess
{
    return [UIColor csg_highlightColor];
}

+ (UIColor *)csg_gradingRailStatusColorFailure
{
    return [UIColor csg_gradeColorRed];
}

+ (UIColor *)csg_gradingRailStatusActivityIndicatorColor
{
    return RGB(150, 150, 150);
}

#pragma mark - Grading Comments Colors

+ (UIColor *)csg_gradingCommentTableBackgroundColor {
    return RGB(248, 249, 246);
}
+ (UIColor *)csg_gradingCommentContainerBackgroundColor {
    return RGB(255, 255, 255);
}
+ (UIColor *)csg_gradingCommentTextColor {
    return RGB(10, 10, 11);
}
+ (UIColor *)csg_gradingCommentDateTextColor {
    return RGB(10, 10, 11);
}

+ (UIColor *)csg_gradingCommentPostCommentSeparatorColor {
    return RGB(215, 215, 211);
}

+ (UIColor *)csg_gradingCommentPostCommentSegmentColor {
    return [UIColor csg_defaultGradingRailGrey];
}

+ (UIColor *)csg_gradingCommentPostCommentBackgroundColor {
    return RGB(255, 255, 255);
}

+ (UIColor *)csg_gradingCommentPostCommentButtonBackgroundColor
{
    return [UIColor csg_highlightColor];
}

+ (UIColor *)csg_gradingCommentTrashCommentButtonColor
{
    return RGB(75, 75, 75);
}

+ (UIColor *)csg_gradingCommentPostCommentButtonDisabledBackgroundColor
{
    return [UIColor csg_defaultGradingRailGrey];
}

+ (UIColor *)csg_gradingCommentPostCommentButtonTextColor
{
    return RGB(255, 255, 255);
}

+ (UIColor *)csg_gradingCommentPostCommentButtonDisabledTextColor
{
    return RGB(255, 255, 255);
}

#pragma mark - Other Colors

+ (NSArray *)csg_courseColors
{
    return @[
             [UIColor csg_red],
             [UIColor csg_pink],
             [UIColor csg_maroon],
             [UIColor csg_purple],
             [UIColor csg_deepPurple],
             [UIColor csg_indigo],
             [UIColor csg_blue],
             [UIColor csg_lightBlue],
             [UIColor csg_cyan],
             [UIColor csg_teal],
             [UIColor csg_lightGreen],
             [UIColor csg_orange],
             [UIColor csg_deepOrange],
             [UIColor csg_lightPink],
             [UIColor csg_gray],
             ];
}

+ (NSArray *)csg_courseColorNames
{
    return @[
             @"Red",
             @"Pink",
             @"Maroon",
             @"Purple",
             @"Deep Purple",
             @"Indigo",
             @"Blue",
             @"Light Blue",
             @"Cyan",
             @"Teal",
             @"Light Green",
             @"Yellow",
             @"Orange",
             @"Deep Orange",
             @"Light Pink",
             @"Gray",
             ];
}

+ (UIColor *)csg_red
{
    return RGB(237, 69, 63);
}

+ (UIColor *)csg_pink
{
    return RGB(231, 36, 102);
}

+ (UIColor *)csg_purple
{
    return RGB(143, 65, 150);
}

+ (UIColor *)csg_deepPurple
{
    return RGB(101, 76, 156);
}

+ (UIColor *)csg_indigo
{
    return RGB(69, 87, 162);
}

+ (UIColor *)csg_blue
{
    return RGB(38, 133, 195);
}

+ (UIColor *)csg_lightBlue
{
    return RGB(57, 166, 219);
}

+ (UIColor *)csg_cyan
{
    return RGB(29, 189, 211);
}

+ (UIColor *)csg_teal
{
    return RGB(22, 152, 137);
}

+ (UIColor *)csg_lightGreen
{
    return RGB(77, 175, 84);
}

+ (UIColor *)csg_maroon
{
    return RGB(134, 19, 79);
}

+ (UIColor *)csg_orange
{
    return RGB(246, 151, 49);
}

+ (UIColor *)csg_deepOrange
{
    return RGB(238, 89, 54);
}

+ (UIColor *)csg_lightPink
{
    return RGB(238, 101, 147);
}

+ (UIColor *)csg_gray
{
    return RGB(81, 85, 96);
}

+ (UIColor *)csg_black
{
    return RGB(0, 0, 0);
}

+ (UIColor *)csg_lightGray
{
    return [UIColor colorWithHex:0xBEBDB8];
}

+ (UIColor *)csg_offWhite
{
    return RGB(246, 246, 242);
}

+ (UIColor *)csg_offWhiteLowAlpha
{
    return RGBA(246, 246, 242, 0.9);
}

+ (UIColor *)csg_offWhiteBorder
{
    return [UIColor colorWithHex:0xbebeb9];
}

+ (UIColor *)csg_tappableButtonBackgroundColor
{
    return [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.3];
}

#pragma mark - Grading Colors
+ (UIColor *)csg_gradeColorRed {
    return RGB(236, 69, 70);
}

+ (UIColor *)csg_gradeColorYellow {
    return RGB(247, 211, 102);
}

+ (UIColor *)csg_gradeColorGreen {
    return RGB(142, 196, 80);
}

+ (UIColor *)csg_gradeColorForPercentage:(CGFloat)percentage {
    NSInteger numberOfColorsToGenerate = 11;
    
    UIImage *image = [UIImage imageWithGradientStartColor:[UIColor csg_gradeColorRed] centerColor:[UIColor csg_gradeColorYellow] endColor:[UIColor csg_gradeColorGreen] size:CGSizeMake(1, numberOfColorsToGenerate)];

    percentage = percentage > 0.99 ? 0.99 : percentage;
    percentage = percentage < 0.1 ? 0.1 : percentage;
    CGPoint colorPoint = CGPointMake(0, percentage * numberOfColorsToGenerate);
    return [image colorAtPixel:colorPoint];
    
}

- (UIColor *)lighterColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s * 0.7
                          brightness:MIN(b * 1.3, 1.0)
                               alpha:a];
    return nil;
}

- (UIColor *)darkerColor
{
    CGFloat h, s, b, a;
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a])
        return [UIColor colorWithHue:h
                          saturation:s
                          brightness:b * 0.75
                               alpha:a];
    return nil;
}

@end