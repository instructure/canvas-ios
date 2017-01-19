
//
//  CKIEnrollment.h
//  CanvasKit
//
//  Created by rroberts on 1/10/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIModel.h"

typedef NS_ENUM(NSUInteger, CKIEnrollmentType) {
    CKIEnrollmentTypeStudent,
    CKIEnrollmentTypeTeacher,
    CKIEnrollmentTypeTA,
    CKIEnrollmentTypeObserver,
    CKIEnrollmentTypeMember,
    CKIEnrollmentTypeDesigner,
    CKIEnrollmentTypeUnknown
};

@interface CKIEnrollment : CKIModel

@property (nonatomic) CKIEnrollmentType type;
@property (nonatomic, strong) NSString *role;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSNumber *computedFinalScore;
@property (nonatomic, strong) NSNumber *computedCurrentScore;
@property (nonatomic, strong) NSString *computedFinalGrade;
@property (nonatomic, strong) NSString *computedCurrentGrade;
@property (nonatomic, strong) NSString *currentGradingPeriodID;
@property (nonatomic, strong) NSNumber *currentGradingPeriodScore;
@property (nonatomic, strong) NSString *currentGradingPeriodGrade;
@property (nonatomic) BOOL multipleGradingPeriodsEnabled;
@property (nonatomic, strong) NSString *sectionID;
@property (nonatomic, readonly) BOOL isStudent;

@end
