//
//  CKIClient+CKIPollSubmission.m
//  CanvasKit
//
//  Created by Rick Roberts on 5/23/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient+CKIPollSubmission.h"

@implementation CKIClient (CKIPollSubmission)

- (RACSignal *)createPollSubmission:(CKIPollSubmission *)submission forPoll:(CKIPoll *)poll pollSession:(CKIPollSession *)session
{
    NSString *path = [session.path stringByAppendingPathComponent:@"poll_submissions"];
    return [self createModelAtPath:path parameters:@{@"poll_submissions": @[@{@"poll_choice_id": submission.pollChoiceID}]} modelClass:[CKIPollSubmission class] context:session];
}

@end
