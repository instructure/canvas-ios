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

#import "CKIClient+CKIFolder.h"
#import "CKICourse.h"
#import "CKIFolder.h"
#import "CKIFile.h"

@implementation CKIClient (CKIFolder)

- (RACSignal *)fetchFolder:(NSString *)folderID
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"folders"];
    path = [path stringByAppendingPathComponent:folderID];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIFolder class] context:CKIRootContext];
}

- (RACSignal *)fetchRootFolderForContext:(id <CKIContext>)context
{
    NSString *path = [context.path stringByAppendingPathComponent:@"folders/root"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIFolder class] context:context];
}

- (RACSignal *)fetchFoldersForFolder:(CKIFolder *)folder
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"folders"];
    path =  [path stringByAppendingPathComponent:folder.id];
    path = [path stringByAppendingPathComponent:@"folders"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIFolder class] context:folder.context];
}

- (RACSignal *)fetchFilesForFolder:(CKIFolder *)folder
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"folders"];
    path =  [path stringByAppendingPathComponent:folder.id];
    path = [path stringByAppendingPathComponent:@"files"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIFile class] context:folder.context];
}

- (RACSignal *)fetchFolder:(NSString *)folderID withContext:(id<CKIContext>)context
{
    NSString *path = [context.path stringByAppendingPathComponent:@"folders"];
    path = [path stringByAppendingPathComponent:folderID];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIFolder class] context:context];
}

- (RACSignal *)deleteFolder:(CKIFolder *)folder
{
    NSString *path = [[CKIRootContext.path stringByAppendingPathComponent:@"folders"] stringByAppendingPathComponent:folder.id];
    NSDictionary *params = @{@"force": @"true"};
    return [self deleteObjectAtPath:path modelClass:[CKIFolder class] parameters:params context:nil];
}

- (RACSignal *)createFolder:(CKIFolder *)folder InFolder:(CKIFolder *)parentFolder
{
    NSString *path = [[[CKIRootContext.path stringByAppendingPathComponent:@"folders"] stringByAppendingPathComponent:parentFolder.id] stringByAppendingPathComponent:@"folders"];
    NSDictionary *params = @{@"name": folder.name};
    return [self createModelAtPath:path parameters:params modelClass:[CKIFolder class] context:parentFolder.context];
}

@end
