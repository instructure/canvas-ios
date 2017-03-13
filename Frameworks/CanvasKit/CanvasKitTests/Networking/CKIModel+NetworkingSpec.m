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

#import "Kiwi.h"
#import "CKIClient+TestingClient.h"
#import "CKIModel+Networking.h"

SPEC_BEGIN(CKIModel_NetworkingSpec)

describe(@"A CKIModel", ^{
    [CKIClient useTestClient];
    context(@"when fetching a model by ID", ^{
        CKIModel *model = [CKIModel modelWithID:@"foo"];
        it(@"should call the path method", ^{
            [[CKIClient currentClient] returnResponseObject:@{@"id": @(1234)} forPath:@"path"];
            [[model should] receive:@selector(path) andReturn:@"path"];
            [model refreshWithSuccess:nil failure:nil];
            [[model.id should] equal:@"1234"];
        });
    });
});
SPEC_END
