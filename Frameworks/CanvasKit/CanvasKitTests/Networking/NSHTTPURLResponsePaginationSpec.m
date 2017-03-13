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

#import <Kiwi/Kiwi.h>

#import "NSHTTPURLResponse+Pagination.h"

SPEC_BEGIN(NSHTTPURLResponsePaginationSpec)

describe(@"A paginated response", ^{
    context(@"when created with link headers", ^{
        NSString *LinkHeaderString = @"<https://mobiledev.instructure.com/api/v1/courses/710747/modules?page=3>; rel=\"current\",<https://mobiledev.instructure.com/api/v1/courses/710747/modules?page=4>; rel=\"next\",<https://mobiledev.instructure.com/api/v1/courses/710747/modules?page=2>; rel=\"prev\",<https://mobiledev.instructure.com/api/v1/courses/710747/modules?page=1>; rel=\"first\",<https://mobiledev.instructure.com/api/v1/courses/710747/modules?page=9>; rel=\"last\"";
        
        NSMutableDictionary *headerFields = [NSMutableDictionary new];
        headerFields[@"Link"] = LinkHeaderString;
        
        NSURL *fakeURL = [NSURL URLWithString:@"http://instructure.com/api/v1/fake/"];
        
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:fakeURL statusCode:200 HTTPVersion:@"HTTP/1.1" headerFields:headerFields];
        
        it(@"should have a current page URL", ^{
            [[response.currentPage should] equal:[NSURL URLWithString:@"https://mobiledev.instructure.com/api/v1/courses/710747/modules?page=3"]];
        });
        it(@"should have the next page URL", ^{
            [[response.nextPage should] equal:[NSURL URLWithString:@"https://mobiledev.instructure.com/api/v1/courses/710747/modules?page=4"]];
        });
        it(@"should have the previous page URL", ^{
            [[response.previousPage should] equal:[NSURL URLWithString:@"https://mobiledev.instructure.com/api/v1/courses/710747/modules?page=2"]];
        });
        it(@"should have the first page URL", ^{
            [[response.firstPage should] equal:[NSURL URLWithString:@"https://mobiledev.instructure.com/api/v1/courses/710747/modules?page=1"]];
        });
        it(@"should have the last page URL", ^{
            [[response.lastPage should] equal:[NSURL URLWithString:@"https://mobiledev.instructure.com/api/v1/courses/710747/modules?page=9"]];
        });
    });
});

SPEC_END