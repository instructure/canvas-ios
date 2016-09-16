//
//  CKCanvasAPI+Modules.m
//  CanvasKit
//
//  Created by Jason Larsen on 3/25/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPI+Modules.h"
#import "CKCanvasAPI+Private.h"
#import "CKCanvasAPIResponse.h"
#import "CKPaginationInfo.h"
#import "CKModule.h"
#import "CKModuleItem.h"

@implementation CKCanvasAPI (Modules)

- (void)fetchModulesForCourseID:(uint64_t)courseID pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block
{
    NSURL *url = pageURLOrNil;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/modules?per_page=%d", self.apiProtocol, self.hostname, courseID, self.itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    
    [self runForPaginatedURL:url withMapping:^(NSDictionary *info) {
        return [CKModule moduleWithInfo:info];
    } completion:block];
}

- (void)fetchModuleItemsForCourseID:(uint64_t)courseID moduleID:(uint64_t)moduleID pageURL:(NSURL *)pageURLOrNil block:(CKPagedArrayBlock)block
{
    NSURL *url = pageURLOrNil;
    if (!url) {
        NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/courses/%qu/modules/%qu/items?per_page=%d",
                               self.apiProtocol, self.hostname, courseID, moduleID, self.itemsPerPage];
        url = [NSURL URLWithString:urlString];
    }
    
    [self runForPaginatedURL:url withMapping:^(NSDictionary *info) {
        return [CKModuleItem itemWithInfo:info];
    } completion:block];
}

@end
