//
//  CBIModuleProgressNotifications.h
//  iCanvas
//
//  Created by Derrick Hathaway on 4/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CanvasKit;

extern NSString *const CBIModuleItemProgressUpdatedNotification;
extern NSString *const CBIUpdatedModuleItemIDStringKey;
extern NSString *const CBIUpdatedModuleItemTypeKey; // will be one of CKIModuleItemType*
extern NSString *const CBISelectedModuleItemIDStringKey; // will be one of CKIModuleItemType*

extern NSString *const CBIModuleProgressUpdatedNotification;
extern NSString *const CBIUpdatedModuleIDKey;


void CBIPostModuleItemProgressUpdate(NSString *itemID, NSString *completionRequirement);
void CBIPostModuleProgressUpdate(NSString *moduleID);
void CBIPostProgressionMadeModuleItemActiveUpdate(NSString *itemID);
