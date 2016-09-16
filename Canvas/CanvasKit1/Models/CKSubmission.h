//
//  CKSubmission.h
//  CanvasKit
//
//  Created by Zach Wily on 5/17/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
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

- (id)initPlaceholderForStudent:(CKStudent *)student andAssignment:(CKAssignment *)assignment;
- (id)initWithInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment;
- (void)updateWithInfo:(NSDictionary *)info;
- (void)updateCommentsWithInfo:(NSDictionary *)info;
- (void)updateCommentsWithSubmission:(CKSubmission *)otherSubmission;
- (void)updateGradeWithInfo:(NSDictionary *)info;

- (CKSubmissionAttempt *)lastAttempt;

+ (NSString *)internalIdentForInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment;
+ (CKStudent *)studentForInfo:(NSDictionary *)info andAssignment:(CKAssignment *)anAssignment;
+ (NSString *)gradeStringForAssignment:(CKAssignment *)assignment andSubmission:(CKSubmission *)submission;
+ (NSString *)gradeStringForAssignment:(CKAssignment *)assignment andAttempt:(CKSubmissionAttempt *)attempt;

@end
