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

#import "CKIAPIV1.h"

@implementation CKIAPIV1
+ (instancetype)context {
    static CKIAPIV1 *apiV1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        apiV1 = [CKIAPIV1 new];
    });
    return apiV1;
}

- (NSString *)path
{
    return @"/api/v1";
}

- (void)setContext:(id<CKIContext>)context
{
    [self doesNotRecognizeSelector:_cmd];
}

- (id<CKIContext>)context {
    return nil;
}

@end
