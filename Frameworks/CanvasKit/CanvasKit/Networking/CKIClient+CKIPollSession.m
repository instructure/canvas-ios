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

#import "CKIClient+CKIPollSession.h"

@implementation CKIClient (CKIPollSession)

- (RACSignal *)createPollSession:(CKIPollSession *)session forPoll:(CKIPoll *)poll
{
    NSString *path = [poll.path stringByAppendingPathComponent:@"poll_sessions"];
    return [self createModelAtPath:path parameters:@{@"poll_sessions": @[@{@"course_id": session.courseID, @"course_section_id": session.sectionID}]} modelClass:[CKIPollSession class] context:poll];
}

- (RACSignal *)deletePollSession:(CKIPollSession *)session
{
    return [self deleteObjectAtPath:session.path modelClass:[CKIPollSession class] parameters:0 context:nil];
}

- (RACSignal *)fetchOpenPollSessionsForCurrentUser
{
    NSString *path = [[CKIRootContext.path stringByAppendingPathComponent:@"poll_sessions"] stringByAppendingPathComponent:@"opened"];
    return [self fetchResponseAtPath:path parameters:0 modelClass:[CKIPollSession class] context:nil];
}

- (RACSignal *)fetchClosedPollSessionsForCurrentUser
{
    NSString *path = [[CKIRootContext.path stringByAppendingPathComponent:@"poll_sessions"] stringByAppendingPathComponent:@"closed"];
    return [self fetchResponseAtPath:path parameters:0 modelClass:[CKIPollSession class] context:nil];
}

- (RACSignal *)fetchPollSessionsForPoll:(CKIPoll *)poll
{
    NSString *path = [poll.path stringByAppendingPathComponent:@"poll_sessions"];
    return [self fetchResponseAtPath:path parameters:0 modelClass:[CKIPollSession class] context:nil];
}

- (RACSignal *)fetchResultsForPollSession:(CKIPollSession *)pollSession
{
    return [self fetchResponseAtPath:pollSession.path parameters:0 modelClass:[CKIPollSession class] context:nil];
}

- (RACSignal *)publishPollSession:(CKIPollSession *)session
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSString *path = [session.path stringByAppendingPathComponent:@"open"];
        NSURLSessionDataTask *task = [self GET:path parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            responseObject = responseObject[@"poll_sessions"];
            [subscriber sendNext:[responseObject firstObject]];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

- (RACSignal *)closePollSession:(CKIPollSession *)session
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSString *path = [session.path stringByAppendingPathComponent:@"close"];
        NSURLSessionDataTask *task = [self GET:path parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            responseObject = responseObject[@"poll_sessions"];
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
            [subscriber sendCompleted];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
}

@end
