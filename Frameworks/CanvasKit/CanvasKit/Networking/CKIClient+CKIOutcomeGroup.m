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
