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
