//
//  CSGUserPrefsKeys.h
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const CSGUserPrefsHideNames;
extern NSString * const CSGUserPrefsShowUngradedFirst;
extern NSString * const CSGColorStoreUserPrefKey;
extern NSString * const CSGSidebarViewModeUserPrefKey;
extern NSString * const CSGStudentPickerSortOrderUserPrefKey;
extern NSString * const CSGUserPrefsAudioPlaybackSpeed;
extern NSString * const CSGUserPrefsShowSourceCode;
extern NSString * const CSGUserPrefsIgnorePermissionsRequest;

@interface CSGUserPrefsKeys : NSObject

+ (void)registerDefaults;
+ (void)saveColor:(UIColor *)color forCourseID:(NSString *)courseID sendToAPI:(BOOL)sendToAPI;
+ (UIColor *)colorForCourseID:(NSString *)courseID;
+ (UIColor *)secondaryColorForCourseID:(NSString *)courseID;
+ (NSString *)userSpecificPrefWithKey:(NSString *)key;

@end
