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

@import ReactiveObjC;

#import "CKIClient+CKIModuleItem.h"
#import "CKIModuleItem.h"
#import "CKIModule.h"

@implementation CKIClient (CKIModuleItem)

- (RACSignal *)fetchModuleItem:(NSString *)moduleItemID forModule:(CKIModule *)module
{
    NSString *path = [module.path stringByAppendingPathComponent:@"items"];
    path = [path stringByAppendingPathComponent:moduleItemID];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIModuleItem class] context:module];
}

- (RACSignal *)fetchModuleItemsForModule:(CKIModule *)module
{
    NSString *path = [module.path stringByAppendingPathComponent:@"items"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIModuleItem class] context:module];
}

- (RACSignal *)markModuleItemAsDone:(CKIModuleItem *)item
{
    NSParameterAssert(item);

    NSString *path = [item.path stringByAppendingPathComponent:@"done"];

    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        if (self) {
            NSURLSessionDataTask *task = [self PUT:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                [subscriber sendCompleted];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [subscriber sendError:error];
            }];

            return [RACDisposable disposableWithBlock:^{
                [task cancel];
            }];
        }

        [subscriber sendError:[NSError errorWithDomain:@"com.instructure.icanvas" code:item.id.integerValue userInfo:@{NSLocalizedDescriptionKey: @"The client died before you got around to marking this item \"done\""}]];

        return [RACDisposable disposableWithBlock:^{
            // empty on purpose yo
        }];
    }];
}

- (RACSignal *)markModuleItemAsRead:(CKIModuleItem *)item
{
    NSParameterAssert(item);

    NSString *path = [item.path stringByAppendingPathComponent:@"mark_read"];

    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        if (self) {
            NSURLSessionDataTask *task = [self POST:path parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                [subscriber sendCompleted];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [subscriber sendError:error];
            }];

            return [RACDisposable disposableWithBlock:^{
                [task cancel];
            }];
        }

        [subscriber sendError:[NSError errorWithDomain:@"com.instructure.icanvas" code:item.id.integerValue userInfo:@{NSLocalizedDescriptionKey: @"The client died before you got around to marking this item \"done\""}]];

        return [RACDisposable disposableWithBlock:^{
            // empty on purpose yo
        }];
    }];
}

@end
