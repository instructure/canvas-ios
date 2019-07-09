//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

#import <Foundation/Foundation.h>
#import <CanvasKit1/CKModelObject.h>
#import <CanvasKit1/CKSubmissionType.h>

extern NSString *CKDiscussionAttemptFilename;

@class CKCanvasAPI, CKSubmission;

@interface CKSubmissionAttempt : CKModelObject

@property (nonatomic, strong) NSString *internalIdent;
@property (nonatomic, assign) uint64_t assignmentIdent;
@property (nonatomic, assign) uint64_t submitterIdent;
@property (nonatomic, assign) int attempt;
@property (nonatomic, weak) CKSubmission *submission;
@property (nonatomic, strong) NSDate *submittedAt;
@property BOOL unsupportedFormat;
@property (nonatomic, strong) NSNumber *score;
@property (nonatomic, strong) NSString *grade;
@property (strong, nonatomic, readonly) NSMutableArray *attachments;
@property (strong, nonatomic, readonly) NSArray *discussionEntries;
@property (nonatomic, assign) CKSubmissionType type;
@property (nonatomic, strong) NSURL *previewURL; // The URL that is used to load quizzes in the webview
@property (nonatomic, strong) NSURL *liveURL; // If this submission has contents in the url (a website submission), this is the URL to the live version
@property (nonatomic) BOOL gradeMatchesCurrentSubmission;

- (id)initWithInfo:(NSDictionary *)info andSubmission:(CKSubmission *)aSubmission;
- (void)updateWithInfo:(NSDictionary *)info;
- (void)updateGradeInfoWithInfo:(NSDictionary *)info;

+ (NSString *)internalIdentForInfo:(NSDictionary *)info andSubmission:(CKSubmission *)submission;

- (NSComparisonResult)compare:(CKSubmissionAttempt *)other;

@end
