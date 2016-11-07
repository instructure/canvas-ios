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
