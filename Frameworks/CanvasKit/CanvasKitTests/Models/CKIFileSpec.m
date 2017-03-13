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
#import "Helpers.h"
#import "CKIISO8601DateMatcher.h"
#import "CKIFile.h"
#import "CKILockInfo.h"

SPEC_BEGIN(CKIFileSpec)

registerMatchers(@"CKI");

describe(@"A file", ^{
    context(@"when created from JSON", ^{
        NSDictionary *json = loadJSONFixture(@"file");
        CKIFile *file = [CKIFile modelFromJSONDictionary:json];
        
        it(@"gets the ID", ^{
            [[file.id should] equal:@"569"];
        });
        it(@"gets the content lock", ^{
            [[file.lockInfo shouldNot] beNil];
        });
        it(@"gets the size", ^{
            [[theValue(file.size) should] equal:theValue(4)];
        });
        it(@"gets the content type", ^{
            [[file.contentType should] equal:@"text/plain"];
        });
        it(@"gets the name", ^{
            [[file.name should] equal:@"file.txt"];
        });
        it(@"gets the url", ^{
            NSURL *url = [NSURL URLWithString:@"http://www.example.com/files/569/download?download_frd=1/u0026verifier=c6HdZmxOZa0Fiin2cbvZeI8I5ry7yqD7RChQzb6P"];
            [[file.url should] equal:url];
        });
        it(@"gets the created at date", ^{
            [[file.createdAt should] equalISO8601String:@"2012-07-06T14:58:50Z"];
        });
        it(@"gets the updated at date", ^{
            [[file.updatedAt should] equalISO8601String:@"2012-07-06T14:58:50Z"];
        });
        it(@"gets hidden for user", ^{
            [[theValue(file.isHiddenForUser) should] beTrue];
        });
        it(@"gets thumbnail URL", ^{
            NSURL *url = [NSURL URLWithString:@"http://www.instructure.testing/this/url"];
            [[file.thumbnailURL should] equal:url];
        });
    });
});

SPEC_END