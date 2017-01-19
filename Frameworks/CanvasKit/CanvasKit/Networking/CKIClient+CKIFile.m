//
//  CKIClient+CKIFile.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import ReactiveObjC;
@import AFNetworking;
#import "CKIClient+CKIFile.h"
#import "CKIFile.h"
#import "CKIFolder.h"

@implementation CKIClient (CKIFile)

- (RACSignal *)fetchFile:(NSString *)fileID
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"files"];
    path = [path stringByAppendingPathComponent:fileID];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIFile class] context:nil];
}

- (RACSignal *)deleteFile:(CKIFile *)file
{
    NSString *path = [[CKIRootContext.path stringByAppendingPathComponent:@"files"] stringByAppendingPathComponent:file.id];
    return [self deleteObjectAtPath:path modelClass:[CKIFile class] parameters:0 context:nil];
}

- (RACSignal *)uploadFile:(NSData *)fileData ofType:(NSString *)fileType withName:(NSString *)name inFolder:(CKIFolder *)folder
{
    NSString *path = [[[CKIRootContext.path stringByAppendingPathComponent:@"folders"] stringByAppendingPathComponent:folder.id] stringByAppendingPathComponent:@"files"];
    return [[self fileUploadTokenSignalForPath:path file:fileData fileName:name folder:folder] flattenMap:^ __kindof RACStream * _Nullable(NSDictionary *fileUploadInfo) {
        return [self uploadFile:fileData ofType:fileType withName:name withFileUploadInfo:fileUploadInfo inFolder:folder];
    }];
}

- (RACSignal *)fileUploadTokenSignalForPath:(NSString *)path file:(NSData *)fileData fileName:(NSString *)fileName folder:(CKIFolder *)folder
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSURLSessionDataTask *task = [self POST:path parameters:@{@"name": fileName, @"size": @(fileData.length), @"parent_folder_id": folder.id, @"on_duplicate": @"rename"} success:^(NSURLSessionDataTask *task, id responseObject) {
            [subscriber sendNext:responseObject];
            [subscriber sendCompleted];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [subscriber sendError:error];
            [subscriber sendCompleted];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [task cancel];
        }];
    }];
    
}

- (RACSignal *)uploadFile:(NSData *)fileData ofType:(NSString *)fileType withName:(NSString *)fileName withFileUploadInfo:(NSDictionary *)uploadInfo inFolder:(CKIFolder *)folder
{
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        AFHTTPSessionManager *uploadOperationManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:uploadInfo[@"upload_url"]]];
        uploadOperationManager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSURLSessionDataTask *uploadOperation = [uploadOperationManager POST:@"" parameters:uploadInfo[@"upload_params"] constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [formData appendPartWithFileData:fileData name:@"file" fileName:fileName mimeType:@"application/octet-stream"];
        } success:^(NSURLSessionDataTask *operation, id responseObject) {
            
            CKIFile *newFile = (CKIFile *) [self parseModel:[NSValueTransformer mtl_JSONDictionaryTransformerWithModelClass:[CKIFile class]] fromJSON:responseObject context:folder.context];
            [subscriber sendNext:newFile];
            [subscriber sendCompleted];
            
        } failure:^(NSURLSessionDataTask *operation, NSError *error) {
            [subscriber sendError:error];
            [subscriber sendCompleted];
        }];
        
        return [RACDisposable disposableWithBlock:^{
            [uploadOperation cancel];
        }];
    }];
}

@end
