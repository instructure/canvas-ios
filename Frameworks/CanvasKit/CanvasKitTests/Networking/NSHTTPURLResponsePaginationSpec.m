//
//  NSHTTPURLResponsePaginationSpec.m
//  CanvasKit
//
//  Created by Jason Larsen on 9/20/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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