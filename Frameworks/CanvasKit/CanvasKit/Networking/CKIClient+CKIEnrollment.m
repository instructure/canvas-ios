//
//  CKIClient+CKIEnrollment.m
//  CanvasKit
//
//  Created by Derrick Hathaway on 8/8/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import "CKIClient+CKIEnrollment.h"

@implementation CKIClient (CKIEnrollment)
- (RACSignal *)fetchEnrollmentsForCourse:(CKICourse *)course ofTypes:(NSArray *)enrollmentTypes forUserWithID:(NSString *)userID {
    
    NSString *path = [course.path stringByAppendingPathComponent:@"enrollments"];
    return [self fetchResponseAtPath:path parameters:@{
       @"user_id": userID,
       @"type": enrollmentTypes,
   } modelClass:[CKIEnrollment class] context:nil];
}
@end
