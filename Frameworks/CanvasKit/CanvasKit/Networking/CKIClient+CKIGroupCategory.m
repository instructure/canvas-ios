//
//  CKIClient+CKIGroupCategory.m
//  CanvasKit
//
//  Created by Brandon Pluim on 12/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient+CKIGroupCategory.h"

#import "CKIGroupCategory.h"
#import "CKIUser.h"
#import "CKICourse.h"

@implementation CKIClient (CKIGroupCategory)

- (RACSignal *)fetchGroupCategoriesForCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"group_categories"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIGroupCategory class] context:nil];
}

- (RACSignal *)fetchUsersInGroupCategory:(CKIGroupCategory *)category
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"group_categories"];
    path = [path stringByAppendingPathComponent:category.id];
    path = [path stringByAppendingPathComponent:@"users"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIUser class] context:nil];
}

@end
