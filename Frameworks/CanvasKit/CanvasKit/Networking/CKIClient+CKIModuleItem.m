//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
