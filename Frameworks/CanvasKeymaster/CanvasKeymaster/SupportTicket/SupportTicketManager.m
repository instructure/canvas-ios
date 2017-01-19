//
//  SupportTicketManager.m
//  iCanvas
//
//  Created by Rick Roberts on 8/21/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "SupportTicketManager.h"
@import ReactiveObjC;
@import CocoaLumberjack;
#import "CanvasKeymaster.h"

static NSString *const ERRORS_PATH = @"error_reports.json";

@implementation SupportTicketManager

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (!self) {
        return nil;
    }
    
    self.requestSerializer = [AFJSONRequestSerializer serializer];
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [self.requestSerializer clearAuthorizationHeader];
    
    return self;
}

- (void)sendTicket:(SupportTicket *)ticket withSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure
{
    [self POST:ERRORS_PATH parameters:[ticket dictionaryValue] progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
    }];
}

@end
