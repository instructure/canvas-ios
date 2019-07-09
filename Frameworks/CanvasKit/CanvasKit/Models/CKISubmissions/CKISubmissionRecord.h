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

#import "CanvasKit.h"
#import "CKIAssignment.h"
#import "CKISubmission.h"

@interface CKISubmissionRecord : CKISubmission

/**
 Comments left by graders. An array of CKISubmissionComment objects.
 */
@property (nonatomic, copy) NSArray *comments;

/**
 * An array of CKISubmissions history of submissions for this particular
 * user on this particular assignment, in order of least to most recent.
 */
@property (nonatomic, copy) NSArray *submissionHistory;

/**
 * RubricAssessment associated with submission, nil if no assessment
 */
@property (nonatomic, copy) CKIRubricAssessment *rubricAssessment;

@property (nonatomic) CKIAssignment *context;

- (BOOL)isDummySubmission;

- (CKISubmission *)defaultAttempt;

@end
