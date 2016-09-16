//
//  CKEnrollment.h
//  CanvasKit
//
//  Created by Joshua Dutton on 5/31/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "CKModelObject.h"

typedef enum : NSUInteger {
    CKEnrollmentTypeUnknown     = 0,
    CKEnrollmentTypeStudent     = 1 << 0,
    CKEnrollmentTypeTeacher     = 1 << 1,
    CKEnrollmentTypeTA          = 1 << 2,
    CKEnrollmentTypeObserver    = 1 << 3,
    CKEnrollmentTypeGroupMember = 1 << 4,
    CKEnrollmentTypeDesigner    = 1 << 5,
    CKEnrollmentTypeStudentView = 1 << 6
} CKEnrollmentType;

@interface CKEnrollment : CKModelObject

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, assign) uint64_t courseId;
@property (nonatomic, assign) uint64_t courseSectionId;
@property (nonatomic, copy) NSString *enrollmentState;
@property (nonatomic, assign) BOOL limitPrivilegesToCourseSection;
@property (nonatomic, assign) uint64_t rootAccountId;
@property (nonatomic, readonly, copy) NSString *typeString;
@property (nonatomic, readonly, copy) NSString *shortName;
@property (nonatomic) CKEnrollmentType type;
@property (nonatomic, assign) uint64_t userId;
@property (nonatomic, assign) uint64_t associatedUserId;
@property (nonatomic, copy) NSURL *htmlURL;
@property (nonatomic, copy) NSURL *gradeURL;

- (id)initWithInfo:(NSDictionary *)info;

- (void)updateWithInfo:(NSDictionary *)info;

+ (NSString *)simpleEnrollmentStringForType:(CKEnrollmentType)type;

@end
