//
//  CKSubmissionAttempt.h
//  CanvasKit
//
//  Created by Zach Wily on 5/20/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
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
@property (nonatomic, assign) float score;
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
