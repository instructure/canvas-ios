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
    
    

#import "CBIModuleProgressNotifications.h"
@import CocoaLumberjack;

extern NSInteger ddLogLevel;

NSString *const CBIModuleItemProgressUpdatedNotification = @"CBIModuleItemProgressUpdatedNotification";

NSString *const CBIUpdatedModuleItemIDStringKey = @"CBIUpdatedModuleItemIDStringKey";
NSString *const CBIUpdatedModuleItemTypeKey = @"CBIUpdatedModuleItemTypeKey";

NSString *const CBISelectedModuleItemIDStringKey = @"CBISelectedModuleItemIDKey";

NSString *const CBIModuleProgressUpdatedNotification = @"CBIModuleProgressUpdatedNotification";
NSString *const CBIUpdatedModuleIDKey = @"CBIUpdatedModuleIDKey";


void CBIPostModuleItemProgressUpdate(NSString *itemID, NSString *completionRequirement)
{
    NSCAssert(itemID != nil, @"must have an item id");
    NSCAssert(completionRequirement != nil, @"must provide a completion requirement");
    
    if (itemID && completionRequirement) {
        NSDictionary *userInfo = @{
                                   CBIUpdatedModuleItemIDStringKey: itemID,
                                   CBIUpdatedModuleItemTypeKey: completionRequirement
                                   };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CBIModuleItemProgressUpdatedNotification object:nil userInfo:userInfo];
    } else {
        DDLogError(@"CBIPostModuleItemProgressUpdate error itemID: %@,",itemID);
        DDLogError(@"CBIPostModuleItemProgressUpdate error completionRequirement: %@",completionRequirement);
    }
}

void CBIPostModuleProgressUpdate(NSString *moduleID)
{
    NSCAssert(moduleID, @"module id required");

    if (moduleID) {
        NSDictionary *userInfo = @{
                                   CBIUpdatedModuleIDKey: moduleID
                                   };
        
        [[NSNotificationCenter defaultCenter] postNotificationName:CBIModuleProgressUpdatedNotification object:nil userInfo:userInfo];
    } else {
        DDLogError(@"CBIPostModuleProgressUpdate attempted to insert nil item into NSDictionary moduleID: %@", moduleID);
    }
}

void CBIPostProgressionMadeModuleItemActiveUpdate(NSString *itemID)
{
    NSCAssert(itemID != nil, @"must have an item id");

    if (itemID) {
        NSDictionary *userInfo = @{
                                   CBISelectedModuleItemIDStringKey: itemID
                                   };

        [[NSNotificationCenter defaultCenter] postNotificationName:CBIModuleItemProgressUpdatedNotification object:nil userInfo:userInfo];
    } else {
        DDLogError(@"CBIPostModuleItemProgressUpdate error itemID: %@,",itemID);
    }
}
