//
//  CKCanvasAPI+ActivityStream.m
//  CanvasKit
//
//  Created by nlambson on 6/11/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPI+ActivityStream.h"
#import "CKCanvasAPI+Private.h"
#import "CKCanvasAPIResponse.h"
#import "CKActivityStreamSummary.h"

@implementation CKCanvasAPI (ActivityStream)

- (void)fetchActivityStreamSummaryWithBlock:(CKObjectBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/users/self/activity_stream/summary", self.apiProtocol, self.hostname];
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    [self runForURL:url
            options:nil
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSArray *responseArray = [apiResponse JSONValue];
                  CKActivityStreamSummary *streamSummary = [CKActivityStreamSummary activityStreamSummary:responseArray];
                  block(nil, isFinalValue, streamSummary);
              }];
}

@end
