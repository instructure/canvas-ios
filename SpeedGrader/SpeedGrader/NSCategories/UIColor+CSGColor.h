//
// UIColor+CSGColor.h
// Created by Jason Larsen on 5/13/14.
//

#import <Foundation/Foundation.h>

// Simple Color Creation Macros
#define RGBA(r, g, b, a) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define RGB(r, g, b) \
[UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define RGB_GREY(grey) \
RGB(grey, grey, grey)

@interface UIColor (CSGColor)

// Colors for Settings
+ (UIColor *)csg_settingsLightBlue;
+ (UIColor *)csg_settingsTextColor;
+ (UIColor *)csg_settingsAvatarBorderColor;

+ (UIColor *)csg_settingsLightGreyTextColor;
+ (UIColor *)csg_settingsDarkGreyTextColor;

+ (UIColor *)csg_settingsSwitchOnColor;
+ (UIColor *)csg_settingsSwitchOffColor;

+ (UIColor *)csg_settingsLogoutButtonColor;
+ (UIColor *)csg_settingsLogoutButtonTintColor;
+ (UIColor *)csg_settingsContainerBackgroundColor;
+ (UIColor *)csg_settingsContainerBorderColor;

+ (UIColor *)csg_settingsBackgroundColor;

// Colors For Section Picker
+ (UIColor *)csg_sectionPickerBackgroundColor;

// Colors for StudentPicker
+ (UIColor *)csg_studentPopoverBackgroundColor;
+ (UIColor *)csg_studentPickerBackgroundColor;
+ (UIColor *)csg_studentPickerHeaderBackgroundColor;
+ (UIColor *)csg_studentPickerHeaderTintColor;
+ (UIColor *)csg_studentPickerFooterBackgroundColor;
+ (UIColor *)csg_studentPickerFooterTextColor;
+ (UIColor *)csg_studentPickerCheckmarkColor;
+ (UIColor *)csg_studentPickerStudentCellBackgroundColor;
+ (UIColor *)csg_studentPickerStudentNameTextColor;
+ (UIColor *)csg_studentPickerLateTextColor;
+ (UIColor *)csg_studentPickerTurnedInCheckColor;
+ (UIColor *)csg_studentPickerStudentGradeTextColor;

// Navigation Bar Color
+ (UIColor *)csg_defaultNavigationBarColor;

// Grading Rail Colors
+ (UIColor *)csg_gradingRailHeaderBackgroundColor;
+ (UIColor *)csg_gradingRailAssignmentNameTextColor;
+ (UIColor *)csg_gradingRailLightSegmentControlColor;
+ (UIColor *)csg_gradingRailDarkSegmentControlColor;
+ (UIColor *)csg_gradingRailRubricSectionViewBackgroundColor;
+ (UIColor *)csg_gradingRailRubricSectionViewTextColor;
+ (UIColor *)csg_gradingRailRubricCriterionTitleTextColor;
+ (UIColor *)csg_gradingRailRubricCriterionPointsTextColor;
+ (UIColor *)csg_gradingRailDefaultBackgroundColor;
+ (UIColor *)csg_gradingPickerBackgroundColor;
+ (UIColor *)csg_gradingRailSubmitGradeButtonBackgroundColor;
+ (UIColor *)csg_gradingRailSubmitGradeDisabledButtonBackgroundColor;
+ (UIColor *)csg_gradingRailSubmitGradeButtonTextColor;
+ (UIColor *)csg_gradingRailSubmitGradeDisabledButtonTextColor;
+ (UIColor *)csg_gradingRailGradeContextLabelTextColor;
+ (UIColor *)csg_gradingRailStatusColorDefault;
+ (UIColor *)csg_gradingRailStatusColorSuccess;
+ (UIColor *)csg_gradingRailStatusColorFailure;
+ (UIColor *)csg_gradingRailStatusActivityIndicatorColor;

// Grading Comment Colors
+ (UIColor *)csg_gradingCommentTableBackgroundColor;
+ (UIColor *)csg_gradingCommentContainerBackgroundColor;
+ (UIColor *)csg_gradingCommentTextColor;
+ (UIColor *)csg_gradingCommentDateTextColor;
+ (UIColor *)csg_gradingCommentPostCommentSeparatorColor;
+ (UIColor *)csg_gradingCommentPostCommentSegmentColor;
+ (UIColor *)csg_gradingCommentPostCommentBackgroundColor;
+ (UIColor *)csg_gradingCommentPostCommentButtonBackgroundColor;
+ (UIColor *)csg_gradingCommentTrashCommentButtonColor;
+ (UIColor *)csg_gradingCommentPostCommentButtonDisabledBackgroundColor;
+ (UIColor *)csg_gradingCommentPostCommentButtonTextColor;
+ (UIColor *)csg_gradingCommentPostCommentButtonDisabledTextColor;

// Grading Colors
+ (UIColor *)csg_gradeColorRed;
+ (UIColor *)csg_gradeColorYellow;
+ (UIColor *)csg_gradeColorGreen;
+ (UIColor *)csg_gradeColorForPercentage:(CGFloat)percentage;

// Other Colors
+ (NSArray *)csg_courseColors;
+ (NSArray *)csg_courseColorNames;

+ (UIColor *)csg_red;
+ (UIColor *)csg_pink;
+ (UIColor *)csg_purple;
+ (UIColor *)csg_deepPurple;
+ (UIColor *)csg_indigo;
+ (UIColor *)csg_blue;
+ (UIColor *)csg_lightBlue;
+ (UIColor *)csg_cyan;
+ (UIColor *)csg_teal;
+ (UIColor *)csg_lightGreen;
+ (UIColor *)csg_orange;
+ (UIColor *)csg_deepOrange;
+ (UIColor *)csg_lightPink;
+ (UIColor *)csg_gray;
+ (UIColor *)csg_black;

+ (UIColor *)csg_offWhiteBorder;
+ (UIColor *)csg_offWhite;
+ (UIColor *)csg_offWhiteLowAlpha;

+ (UIColor *)csg_tappableButtonBackgroundColor;

- (UIColor *)lighterColor;
- (UIColor *)darkerColor;

@end