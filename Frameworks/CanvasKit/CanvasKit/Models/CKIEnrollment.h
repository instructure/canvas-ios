//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
