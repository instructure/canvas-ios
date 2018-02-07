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
#import <UIKit/UIKit.h>
#import "CKSubmissionAttempt.h"
#import "CKContentLock.h"
#import "CKModelObject.h"

typedef enum {
    CKAssignmentTypeAssignment,
    CKAssignmentTypeDiscussion,
    CKAssignmentTypeQuiz,
    CKAssignmentTypeAttendance,
    CKAssignmentTypeExternalTool,
    CKAssignmentTypeNotGraded
} CKAssignmentType;

typedef enum {
    CKAssignmentScoringTypePoints,
    CKAssignmentScoringTypePercentage,
    CKAssignmentScoringTypePassFail,
    CKAssignmentScoringTypeLetter
} CKAssignmentScoringType;

@class CKCanvasAPI, CKCourse, CKSubmission, CKStudent, CKRubric, CKDiscussionTopic;

@interface CKAssignment : CKModelObject

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, assign) CKAssignmentType type;
@property (nonatomic, strong) NSString *name;
@property uint64_t courseIdent;
@property (nonatomic, weak) CKCourse *course;
@property (nonatomic, copy) NSString *assignmentDescription;
@property (nonatomic, strong) NSDate *dueDate;
@property (strong, nonatomic, readonly) NSMutableDictionary *submissions;
@property (nonatomic, strong) CKRubric *rubric;
@property (nonatomic, assign) CKAssignmentScoringType scoringType;
@property (nonatomic, assign) double pointsPossible;
@property (nonatomic, assign) uint64_t assignmentGroupId;
@property (nonatomic, assign) NSNumber *groupCategoryID; // for group assignments
@property (nonatomic, assign) NSInteger position;
@property (nonatomic, strong) CKDiscussionTopic *discussionTopic;
@property BOOL useRubricForGrading;
@property (nonatomic, assign) CKSubmissionType submissionTypes; //bitfield
@property (nonatomic) NSInteger needsGradingCount;
@property (nonatomic) BOOL anonymousSubmissions;
@property (nonatomic, strong) NSArray *allowedExtensions;
@property (nonatomic, assign) uint64_t quizIdent;
@property (nonatomic) NSURL *url;
@property (readonly) CKContentLock *contentLock;
@property (nonatomic, strong) NSURL *externalToolTagAttributesURL;

@property (nonatomic, readonly) NSURL *urlForSubmissionFileUpload;

- (id)initWithInfo:(NSDictionary *)info;

- (void)updateWithInfo:(NSDictionary *)info;

+ (CKAssignmentType)assignmentTypeForSubmissionsTypes:(NSArray *)submissionTypeStrings;

// Makes sure the provided extension is allowed by this assignment for submissions
- (BOOL)allowsExtension:(NSString *)extension;
// For informing the user that they're trying to submit a file with an unpermitted extension
- (NSString *)notAllowedAlertTitle:(NSString *)extension;
- (NSString *)notAllowedAlertMessage;

- (NSComparisonResult)comparePosition:(CKAssignment *)other;

- (NSString *)gradeStringForSubmission:(CKSubmission *)submission usingEnteredGrade:(BOOL)useEnteredGrade;
@end

@interface CKAssignment (SpeedGrader)
- (id)initWithInfo:(NSDictionary *)info andCourse:(CKCourse *)course __attribute__((deprecated("Use -setCourse:")));
- (void)updateNeedsGradingCount;
- (CKSubmission *)submissionForStudent:(CKStudent *)student;
@end
