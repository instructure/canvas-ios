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
