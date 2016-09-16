//
//  CKCanvasAPI+LTI.m
//  CanvasKit
//
//  Created by derrick on 6/24/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPI+ExternalTool.h"
#import "CKCanvasAPI+Private.h"
#import "CKCanvasAPIResponse.h"

extern NSString * const CKAPIShouldIgnoreCacheKey;

@implementation CKCanvasAPI (ExternalTool)
- (void)fetchExternalToolSessionURLForCanvasURL:(NSURL *)canvasExternalToolURL block:(void (^)(NSError *error, NSURL *externalURL))completion
{
    [self runForURL:canvasExternalToolURL options:@{CKAPIShouldIgnoreCacheKey : @YES} block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
        completion(error, [NSURL URLWithString:apiResponse.JSONValue[@"url"]]);
    }];
}
@end
