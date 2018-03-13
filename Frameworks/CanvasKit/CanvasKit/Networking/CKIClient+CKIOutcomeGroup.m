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

#import "CKIClient+CKIOutcomeGroup.h"

@import ReactiveObjC;
#import "CKIOutcomeGroup.h"
#import "CKICourse.h"

@implementation CKIClient (CKIOutcomeGroup)

- (RACSignal *)fetchRootOutcomeGroupForCourse:(CKICourse *)course
{
    @weakify(self);
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self setTaskWillPerformHTTPRedirectionBlock:^NSURLRequest *(NSURLSession *session, NSURLSessionTask *task, NSURLResponse *response, NSURLRequest *request) {
            @strongify(self);
            NSInteger pathOffset = [[[self baseURL] absoluteString] length] + [course.path length] + [@"outcome_groups/" length];
            NSString *rootOutcomeID = [[[request URL] absoluteString] substringFromIndex:pathOffset];
            [subscriber sendNext:rootOutcomeID];
            
            [task cancel];
            
            return request;
        }];
        
        return [RACDisposable disposableWithBlock:^{
            
        }];
    }];

    NSString *path = [course.path stringByAppendingPathComponent:@"root_outcome_group"];
    [self fetchResponseAtPath:path parameters:nil modelClass:[CKIOutcomeGroup class] context:course];
    
    return signal;
}

- (RACSignal *)fetchOutcomeGroupForCourse:(CKICourse *)course id:(NSString *)identifier
{
     NSString *path = [course.path stringByAppendingPathComponent:[NSString stringWithFormat:@"outcome_groups/%@", identifier]];
    return [[self fetchResponseAtPath:path parameters:nil modelClass:[CKIOutcomeGroup class] context:course] map:^id(CKIOutcomeGroup *outcomegroup) {
        outcomegroup.context = course;
        return outcomegroup;
    }];
}

- (RACSignal *)fetchSubGroupsForOutcomeGroup:(CKIOutcomeGroup *)group
{
    NSString *path = [group.path stringByAppendingPathComponent:@"subgroups"];
    return [[self fetchResponseAtPath:path parameters:nil modelClass:[CKIOutcomeGroup class] context:group.context] map:^id(NSArray *subgroups) {
        [subgroups enumerateObjectsUsingBlock:^(CKIOutcomeGroup *subgroup, NSUInteger idx, BOOL *stop) {
            subgroup.parent = group;
        }];
        return subgroups;
    }];
}

@end
