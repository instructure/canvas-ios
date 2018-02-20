//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

@class CKCanvasAPI, CKAssignment, CKStudent, CKSubmissionAttempt, CKRubricAssessment;

@interface CKSubmission : CKModelObject

// NOTE: ident is actually the user_id, not the submission id
@property (nonatomic, assign) uint64_t ident;
@property (readonly) uint64_t studentIdent;
@property (nonatomic, strong) NSString *internalIdent;
@property (strong, nonatomic, readonly) NSMutableArray *attempts;
@property (nonatomic, weak) CKAssignment *assignment;
@property (nonatomic, weak) CKStudent *student;
@property (weak, nonatomic, readonly) CKSubmissionAttempt *lastAttempt;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, readonly) BOOL isPlaceholder;
@property (nonatomic, assign) float score;
@property (nonatomic, strong) NSString *grade;
@property (nonatomic, strong) CKRubricAssessment *rubricAssessment;
@property (weak, nonatomic, readonly) NSString *displayGrade;
@property (nonatomic, strong) NSDate *freshnessDate;
@property (nonatomic, readonly) BOOL isGraded;
@property (nonatomic, readonly) BOOL needsGrading;
@property (nonatomic, strong) NSNumber *turnitinScore;
@property (nonatomic, assign) float enteredScore;
@property (nonatomic, strong) NSString *enteredGrade;
@property (nonatomic, strong) NSNumber *pointsDeducted;

- (id)initPlaceholderForStudent:(CKStudent *)student andAssignment:(CKAssignment *)assignment;
- (id)initWithInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment;
- (void)updateWithInfo:(NSDictionary *)info;
- (void)updateCommentsWithInfo:(NSDictionary *)info;
- (void)updateCommentsWithSubmission:(CKSubmission *)otherSubmission;
- (void)updateGradeWithInfo:(NSDictionary *)info;
- (BOOL)hasLatePolicyApplied;

- (CKSubmissionAttempt *)lastAttempt;

+ (NSString *)internalIdentForInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment;
+ (CKStudent *)studentForInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment;
+ (NSString *)gradeStringForAssignment:(CKAssignment *)assignment andSubmission:(CKSubmission *)submission;
+ (NSString *)gradeStringForAssignment:(CKAssignment *)assignment andAttempt:(CKSubmissionAttempt *)attempt;

@end
