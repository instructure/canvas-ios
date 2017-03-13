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

extern NSString * const CKISubmissionTypeOnlineTextEntry;
extern NSString * const CKISubmissionTypeOnlineURL;
extern NSString * const CKISubmissionTypeOnlineUpload;
extern NSString * const CKISubmissionTypeMediaRecording;
extern NSString * const CKISubmissionTypeQuiz;
extern NSString * const CKISubmissionTypeDiscussion;
extern NSString * const CKISubmissionTypeExternalTool;
extern NSString * const CKISubmissionTypePaper;
extern NSString * const CKISubmissionTypeLTILaunch;

typedef NS_ENUM(NSInteger, CKISubmissionEnumType) {
    CKISubmissionEnumTypeUnknown            = -1,
    CKISubmissionEnumTypeOnlineTextEntry    = 0,
    CKISubmissionEnumTypeOnlineURL          = 1,
    CKISubmissionEnumTypeOnlineUpload       = 2,
    CKISubmissionEnumTypeMediaRecording     = 3,
    CKISubmissionEnumTypeQuiz               = 4,
    CKISubmissionEnumTypeDiscussion         = 5,
    CKISubmissionEnumTypeExternalTool       = 6,
    CKISubmissionEnumTypePaper              = 7,
    CKISubmissionEnumTypeLTILaunch          = 8,
};

@class CKIAssignment;
@class CKIMediaComment;
@class CKIRubricAssessment;
@class CKIFile;

@interface CKISubmission : CKIModel

/**
 The ID of the assignment this is a submission for.
 */
@property (nonatomic, copy) NSString *assignmentID;

/**
 The attempt number of this submission.
 
 Ex: 4 would indicate that this is the 4th submission
 */
@property (nonatomic) NSUInteger attempt;

/**
 The content of a sumbission if submitted from a text field.
 */
@property (nonatomic, copy) NSString *body;

/**
 The grade for the submission, translated into the assignment
 grading scheme (so a letter grade, for example).
 
 @warning Because you don't have the grading scheme, you
 should not attempt to calculate this string yourself using
 the raw score property.
 
 @see score
 */
@property (nonatomic, copy) NSString *grade;


/**
 False if the student has re-submitted since the submission
 was last graded
 
 @see grade
 */
@property (nonatomic) BOOL gradeMatchesCurrentSubmission;

/**
 The URL of submission if it was a URL submission.
 
 @see CKISubmissionTypeOnlineURL
 */
@property (nonatomic, strong) NSURL *url;

/**
 The URL of the submission in web Canvas.
 */
@property (nonatomic, strong) NSURL *htmlURL;

/**
 The URL of the submission preview.
 */
@property (nonatomic, strong) NSURL *previewURL;

/**
 The raw score of this submission.
 */
@property (nonatomic, strong) NSNumber *score;

/**
 The date the submission was submitted.
 */
@property (nonatomic, strong) NSDate *submittedAt;

/**
 The type of submission.  Returns the string value.  Users should check type when comparing so public values are not available
 
 @see CKISubmissionTypeOnlineTextEntry, CKISubmissionTypeOnlineURL,
 CKISubmissionTypeOnlineUpload, CKISubmissionTypeMediaRecording
 */
@property (nonatomic, copy) NSString *submissionType;

/**
 The type of submission enum
 */
@property (nonatomic, readonly) CKISubmissionEnumType type;

/**
 The ID of the user that created the submission.
 */
@property (nonatomic, copy) NSString *userID;

/**
 The ID of the user that graded the submission.
 */
@property (nonatomic, copy) NSString *graderID;

/**
 The submission was made after the due date.
 */
@property (nonatomic) BOOL late;

/**
 When a submission appears in a conversation, the assignment is also
 available as part of the submission.
 */
@property (nonatomic) CKIAssignment *assignment;

/**
 When submission appears as a media_recording the media comment object is available
 */
@property (nonatomic) CKIMediaComment *mediaComment;

/**
* Any file attachments included with this submission.
* Each attachment is a CKIFile object.
*/
@property (nonatomic, copy) NSArray *attachments;


/**
 An array containing the submitted `CKIDiscussionEntry`s for
 `CKISubmissionTypeDiscussion` type submissions
 */
@property (nonatomic, copy) NSArray *discussionEntries;

- (CKIFile *)defaultAttachment;


@end

