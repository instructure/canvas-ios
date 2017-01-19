 //
//  CKIClient+CKIPollChoice.m
//  CanvasKit
//
//  Created by Rick Roberts on 5/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient+CKIPollChoice.h"

@implementation CKIClient (CKIPollChoice)

- (RACSignal *)fetchPollChoicesForPoll:(CKIPoll *)poll
{
    NSString *path = [poll.path stringByAppendingPathComponent:@"poll_choices"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIPollChoice class] context:poll];
}

- (RACSignal *)fetchPollChoiceWithId:(NSString *)pollChoiceId fromPoll:(CKIPoll *)poll
{
    NSString *path = [[poll.path stringByAppendingPathComponent:@"poll_choices"] stringByAppendingPathComponent:pollChoiceId];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIPollChoice class] context:poll];
}

- (RACSignal *)createPollChoice:(CKIPollChoice *)pollChoice forPoll:(CKIPoll *)poll
{
    NSString *path = [poll.path stringByAppendingPathComponent:@"poll_choices"];
    NSDictionary *parameters = @{@"poll_choices": @[@{@"text": pollChoice.text, @"is_correct": @(pollChoice.isCorrect), @"position": pollChoice.index}]};
    return [self createModelAtPath:path parameters:parameters modelClass:[CKIPollChoice class] context:poll];
}


@end
