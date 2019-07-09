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
