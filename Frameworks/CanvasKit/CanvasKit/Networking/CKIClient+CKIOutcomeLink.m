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
