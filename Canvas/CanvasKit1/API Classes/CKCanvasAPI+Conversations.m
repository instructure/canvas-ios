//
//  CKCanvasAPI+Conversations.m
//  CanvasKit
//
//  Created by nlambson on 6/12/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPI+Conversations.h"
#import "CKCanvasAPI+Private.h"
#import "CKCanvasAPIResponse.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKCanvasAPI (Conversations)

- (void)fetchConversationsUnreadCountWithBlock:(CKObjectBlock)block {
    NSString *urlString = [NSString stringWithFormat:@"%@://%@/api/v1/conversations/unread_count", self.apiProtocol, self.hostname];
    NSURL *url = [NSURL URLWithString:urlString];
    
    block = [block copy];
    [self runForURL:url
            options:nil
              block:^(NSError *error, CKCanvasAPIResponse *apiResponse, BOOL isFinalValue) {
                  if (error != nil) {
                      block(error, isFinalValue, nil);
                      return;
                  }
                  
                  NSDictionary *responseDict = [apiResponse JSONValue];
                  NSDictionary * safeDict = [responseDict safeCopy];
                  block(nil, isFinalValue, safeDict[@"unread_count"]);
              }];
}

@end
