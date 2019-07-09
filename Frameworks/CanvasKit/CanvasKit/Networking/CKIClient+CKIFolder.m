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
