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
