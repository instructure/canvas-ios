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

#import "CKIClient+CKIOutcomeLink.h"

@import ReactiveObjC;
#import "CKIOutcomeLink.h"
#import "CKIOutcome.h"
#import "CKIOutcomeGroup.h"

@implementation CKIClient (CKIOutcomeLink)

- (RACSignal *)fetchOutcomeLinksForOutcomeGroup:(CKIOutcomeGroup *)group
{
    NSString *path = [group.path stringByAppendingPathComponent:@"outcomes"];
    return [[self fetchResponseAtPath:path parameters:nil modelClass:[CKIOutcomeLink class] context:group.context] map:^id(NSArray *outcomes) {
        
        [outcomes enumerateObjectsUsingBlock:^(CKIOutcomeLink *outcomeLink, NSUInteger idx, BOOL *stop) {
            outcomeLink.outcomeGroup = group;
            outcomeLink.id = [NSString stringWithFormat:@"%@-link-%@", @(idx), group.id];
        }];
        return outcomes;
    }];
}

@end
