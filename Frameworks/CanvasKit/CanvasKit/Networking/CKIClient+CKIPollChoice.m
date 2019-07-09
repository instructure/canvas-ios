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
