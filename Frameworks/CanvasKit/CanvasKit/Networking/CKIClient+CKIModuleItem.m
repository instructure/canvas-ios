//
//  CKIClient+CKIModuleItem.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
            NSURLSessionDataTask *task = [self POST:path parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
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
