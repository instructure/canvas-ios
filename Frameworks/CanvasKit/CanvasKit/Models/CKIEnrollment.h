//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
@property (nonatomic, strong) NSNumber *limitPrivilegesToCourseSection;
@property (nonatomic) BOOL multipleGradingPeriodsEnabled;
@property (nonatomic, strong) NSString *sectionID;
@property (nonatomic, readonly) BOOL isStudent;

@end
