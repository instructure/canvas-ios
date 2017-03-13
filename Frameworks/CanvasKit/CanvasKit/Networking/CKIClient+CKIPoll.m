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

#import "CKIClient+CKIPoll.h"
@import ReactiveObjC;

@implementation CKIClient (CKIPoll)

- (RACSignal *)fetchPollsForCurrentUser
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"polls"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIPoll class] context:CKIRootContext];
}

- (RACSignal *)fetchPollWithID:(NSString *)pollID
{
    NSString *path = [[CKIRootContext.path stringByAppendingPathComponent:@"polls"] stringByAppendingPathComponent:pollID];
    
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIPoll class] context:CKIRootContext];
}

- (RACSignal *)createPoll:(CKIPoll *)poll
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"polls"];
    NSDictionary *params = @{
                             @"polls": @[@{@"question": poll.question}]
                             };
    return [self createModelAtPath:path parameters:params modelClass:[CKIPoll class] context:CKIRootContext];
}

- (RACSignal *)deletePoll:(CKIPoll *)poll
{
    return [self deleteObjectAtPath:poll.path modelClass:[CKIPoll class] parameters:nil context:poll];
}

@end
