//
//  SupportTicketManager.h
//  iCanvas
//
//  Created by Rick Roberts on 8/21/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AFNetworking;
#import "SupportTicket.h"

@interface SupportTicketManager : AFHTTPSessionManager

- (void)sendTicket:(SupportTicket *)ticket withSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure;

@end
