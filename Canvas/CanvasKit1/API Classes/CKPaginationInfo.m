//
//  CKPaginationInfo.m
//  CanvasKit
//
//  Created by BJ Homer on 9/19/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import "CKPaginationInfo.h"
#import "NSHTTPURLResponse+CKAdditions.h"

@implementation CKPaginationInfo

- (id)initWithResponse:(NSHTTPURLResponse *)httpResponse {
    self = [super init];
    if (self) {
        
        _currentPage = [httpResponse.URL copy];
        
        NSRange pathLocation = [httpResponse.URL.absoluteString rangeOfString:httpResponse.URL.path];
        NSURL *baseURL = nil;
        if (pathLocation.location != NSNotFound) {
            NSString *rootString = [httpResponse.URL.absoluteString substringToIndex:pathLocation.location];
            baseURL = [NSURL URLWithString:rootString];
        }
        
        NSDictionary *values = [httpResponse ck_linkHeaderValues];
        
        // In theory, all these URLs should be absolute URLs. In practice, the API sometimes
        // returns relative URLs. So we pass the baseURL in, just in case. If the original
        // is an absolute URL, it will be ignored.
        NSString *firstValue = values[@"first"];
        if (firstValue) {
            _firstPage = [[NSURL URLWithString:firstValue relativeToURL:baseURL] absoluteURL];
        }
        
        NSString *prevValue = values[@"prev"];
        if (prevValue) {
            _previousPage = [[NSURL URLWithString:prevValue relativeToURL:baseURL] absoluteURL];
        }
        
        NSString *nextValue = values[@"next"];
        if (nextValue) {
            _nextPage = [[NSURL URLWithString:nextValue relativeToURL:baseURL] absoluteURL];
        }
        
        NSString *lastValue = values[@"last"];
        if (lastValue) {
            _lastPage = [[NSURL URLWithString:lastValue relativeToURL:baseURL] absoluteURL];
        }
    }
    return self;
}

@end
