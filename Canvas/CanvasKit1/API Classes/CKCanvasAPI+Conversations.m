//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
