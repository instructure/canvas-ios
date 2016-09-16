//
//  CBIModuleProgressNotifications.m
//  iCanvas
//
//  Created by Derrick Hathaway on 4/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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