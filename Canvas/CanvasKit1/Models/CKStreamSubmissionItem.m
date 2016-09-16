//
//  CKStreamSubmissionItem.m
//  CanvasKit
//
//  Created by Mark Suman on 9/7/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKStreamSubmissionItem.h"
#import "NSDictionary+CKAdditions.h"
#import "CKAssignment.h"
#import "CKCourse.h"

@implementation CKStreamSubmissionItem

@synthesize grade, score, assignmentDict, submissionComments;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super initWithInfo:info];
    if (self) {
        grade = [info objectForKeyCheckingNull:@"grade"];
        score = [[info objectForKeyCheckingNull:@"score"] intValue];
        assignmentDict = [info objectForKeyCheckingNull:@"assignment"];
        submissionComments = [info objectForKeyCheckingNull:@"submission_comments"];
    }
    
    return self;
}


- (NSDictionary *)latestComment
{
    // TODO: unit test this to make sure it returns the correct one
    NSDictionary *comment = nil;
    
    if ([self.submissionComments count] > 0) {
        comment = [self.submissionComments lastObject];
    }
    
    return comment;
}

- (void)populateActionPath
{
    if (self.actionPath) {
        return;
    }
    
    if (self.assignmentDict) {
        int assignmentId = [(self.assignmentDict)[@"id"] unsignedLongLongValue];
        
        if (assignmentId > 0) {
            self.actionPath = @[[CKCourse class], @(self.courseId), [CKAssignment class], @(assignmentId)];
        }
    }
}

@end
