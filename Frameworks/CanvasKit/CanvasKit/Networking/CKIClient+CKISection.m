//
//  CKIClient+CKISection.m
//  CanvasKit
//
//  Created by Rick Roberts on 5/12/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient+CKISection.h"
#import "CKISection.h"

@implementation CKIClient (CKISection)

- (RACSignal *)fetchSectionsForCourse:(CKICourse *)course
{
    NSString *path = [course.path stringByAppendingPathComponent:@"sections"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKISection class] context:course];
}

- (RACSignal *)fetchSectionWithID:(NSString *)sectionID
{
    NSString *path = [[CKIRootContext.path stringByAppendingPathComponent:@"sections"] stringByAppendingPathComponent:sectionID];
    return [self fetchResponseAtPath:path parameters:0 modelClass:[CKISection class] context:nil];
}

@end
