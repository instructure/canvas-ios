//
//  CSGUserPrefsKeys.m
//  SpeedGrader
//
//  Created by Brandon Pluim on 8/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CSGUserPrefsKeys.h"
#import "CSGColorManager.h"
#import <CanvasKeymaster/CanvasKeymaster.h>

NSString * const CSGUserPrefsHideNames = @"CSGUserPrefsHideNames";
NSString * const CSGUserPrefsShowUngradedFirst = @"CSGUserPrefsShowUngradedFirst";
NSString * const CSGSidebarViewModeUserPrefKey = @"CSGSidebarViewModeUserPrefKey";
NSString * const CSGStudentPickerSortOrderUserPrefKey = @"CSGStudentPickerViewModeUserPrefKey";
NSString * const CSGColorStoreUserPrefKey = @"CSGColorStoreKey";
NSString * const CSGUserPrefsAudioPlaybackSpeed = @"CSGUserPrefsAudioPlaybackSpeed";
NSString * const CSGUserPrefsShowSourceCode = @"CSGUserPrefsShowSourceCspoode";
NSString * const CSGUserPrefsIgnorePermissionsRequest = @"CSGUserPrefsIgnorePermissionsRequest";

@implementation CSGUserPrefsKeys

+ (void)registerDefaults {
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              CSGSidebarViewModeUserPrefKey : @(0),
                                                              CSGStudentPickerSortOrderUserPrefKey : @(0),
                                                              CSGUserPrefsAudioPlaybackSpeed : @(1),
                                                              CSGUserPrefsHideNames : @(0),
                                                              CSGUserPrefsShowUngradedFirst : @(1)
                                                              }];
}

+ (void)saveColor:(UIColor *)color forCourseID:(NSString *)courseID sendToAPI:(BOOL)sendToAPI {
    NSDictionary *colorDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:CSGColorStoreUserPrefKey];
    
    NSMutableDictionary *mutableColorDictionary = [NSMutableDictionary dictionaryWithDictionary:colorDictionary];
    NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:color];
    mutableColorDictionary[courseID] = colorData;
    [[NSUserDefaults standardUserDefaults] setObject:mutableColorDictionary forKey:CSGColorStoreUserPrefKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (sendToAPI) {
        CSGColorManager *colorManager = [CSGColorManager new];
        [colorManager saveColorDataForUserWithSuccess:nil failure:nil];
    }
}

+ (UIColor *)colorForCourseID:(NSString *)courseID {
    NSDictionary *colorDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:CSGColorStoreUserPrefKey];
    if (!colorDictionary) {
        return nil;
    }
    
    NSData *colorData = colorDictionary[courseID];
    if (!colorData) {
        return nil;
    }
    
    return [NSKeyedUnarchiver unarchiveObjectWithData:colorData];
}

+ (UIColor *)secondaryColorForCourseID:(NSString *)courseID {
    UIColor *color = [self colorForCourseID:courseID];
    return [color lighterColor];
}

+ (NSString *)userSpecificPrefWithKey:(NSString *)key {
    return [NSString stringWithFormat:@"%@-%@", key, TheKeymaster.currentClient.currentUser.id];
}

@end
