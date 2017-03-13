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
