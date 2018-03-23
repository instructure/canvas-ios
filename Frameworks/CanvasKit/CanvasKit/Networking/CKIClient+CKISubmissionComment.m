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

#import "CKIClient+CKISubmissionComment.h"
#import "CKISubmissionRecord.h"
#import "CKIMediaFileUPloadTokenParser.h"
#import "CKIMediaServer.h"
@import AFNetworking;

@implementation CKIClient (CKISubmissionComment)

- (RACSignal *)createSubmissionComment:(CKISubmissionComment *)comment {
    
    NSMutableDictionary *commentDictionary = [@{ @"text_comment" : comment.comment } mutableCopy];
    if (comment.mediaComment.mediaID) {
        commentDictionary[@"media_comment_id"] = comment.mediaComment.mediaID;
        commentDictionary[@"media_comment_type"] = comment.mediaComment.mediaType;
    }
    NSDictionary *params = @{@"comment" : commentDictionary};
    return [self updateModel:(CKIModel *)comment.context parameters:params];
}

- (void)createCommentWithMedia:(CKIMediaComment *)mediaComment forSubmissionRecord:(CKISubmissionRecord *)submissionRecord success:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    
    if (!mediaComment.mediaType || !([mediaComment.mediaType isEqualToString:CKIMediaCommentMediaTypeAudio] || [mediaComment.mediaType isEqualToString:CKIMediaCommentMediaTypeVideo])) {
        if (failure) {
            failure([NSError errorWithDomain:@"com.instructure.speedgrader.error" code:-1000 userInfo:@{NSLocalizedDescriptionKey: @"Missing or invalid media type. Accepted types are CKIMediaCommentMediaTypeAudio or CKIMediaCommentMediaTypeVideo. See CKIMediaComment.h"}]);
        }
        return;
    }
    
    [self postMediaCommentAtPath:mediaComment.url.absoluteString ofMediaType:mediaComment.mediaType success:^(NSString *mediaUploadID){
        
        CKISubmissionComment *comment = [[CKISubmissionComment alloc] init];
        mediaComment.mediaID = mediaUploadID;
        comment.mediaComment = mediaComment;
        
        NSString *path = [[[submissionRecord.context path] stringByAppendingPathComponent:@"submissions"] stringByAppendingPathComponent:submissionRecord.userID];
        NSDictionary *params = @{@"media_comment_id": mediaUploadID, @"media_comment_type": mediaComment.mediaType, @"text_comment": @""};
        [self PUT:path parameters:@{@"comment": params} success:^(NSURLSessionDataTask *task, id responseObject) {
            if (success) {
                success();
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getThumbnailForMediaComment:(CKIMediaComment *)mediaComment ofSize:(CGSize)size success:(void(^)(UIImage *image))success failure:(void(^)(NSError *error))failure {
    
    [self configureMediaServerWithSuccess:^{
        NSString *urlString = [NSString stringWithFormat:@"p/%@/thumbnail/entry_id/%@/width/%@/height/%@/bgcolor/000000/type/1/vid_sec/5", self.mediaServer.partnerId, mediaComment.mediaID, @(size.width), @(size.height)];
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.mediaServer.resourceDomain];
        
        manager.responseSerializer = [AFImageResponseSerializer serializer];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            UIImage *image = responseObject;
            if (success) {
                success(image);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if (failure) {
                failure(error);
            }
        }];
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - Private Methods

- (void)postMediaCommentAtPath:(NSString *)path ofMediaType:(NSString *)mediaType success:(void(^)(NSString *mediaUploadID))success failure:(void(^)(NSError *error))failure {
    [self configureMediaServerWithSuccess:^{
        [self getMediaSessionWithSuccess:^(NSString *sessionID) {
            [self getFileUploadTokenWithSessionID:sessionID success:^(NSString *uploadToken) {
                [self uploadFileAtPath:path ofMediaType:mediaType withToken:uploadToken sessionID:sessionID success:^{
                    [self getMediaIDForUploadedFileToken:uploadToken withMediaType:mediaType file:[NSURL URLWithString:path] sessionID:sessionID success:^(NSString *mediaUploadID) {
                        if (success) {
                            success(mediaUploadID);
                        }
                    } failure:^(NSError *error) {
                        if (failure) { failure(error); }
                    }];
                } failure:^(NSError *error) {
                    if (failure) { failure(error); }
                }];
            } failure:^(NSError *error) {
                if (failure) { failure(error); }
            }];
        } failure:^(NSError *error) {
            if (failure) { failure(error); }
        }];
    } failure:^(NSError *error) {
        if (failure) { failure(error); }
    }];

}
- (void)getMediaSessionWithSuccess:(void(^)(NSString *sessionID))success failure:(void(^)(NSError *error))failure {
    NSString *urlString = @"api/v1/services/kaltura_session";
    
    [self POST:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *ks = [responseObject valueForKey:@"ks"];
        if (success) {
            success(ks);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getFileUploadTokenWithSessionID:(NSString *)sessionID success:(void(^)(NSString *uploadToken))success failure:(void(^)(NSError *error))failure {
    NSURL *url = [self.mediaServer apiURLAdd];
    NSDictionary *parameters = @{@"ks": sessionID};
    
    [[self xmlRequestManager] POST:url.absoluteString parameters:parameters progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        // Handle failure to parse
        // Get the token id from the XML
        CKIMediaFileUploadTokenParser *parser = [[CKIMediaFileUploadTokenParser alloc] initWithXMLParser:responseObject];
        [parser parseWithSuccess:^(NSString *uploadID) {
            if (success) {
                success(uploadID);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
}

- (void)uploadFileAtPath:(NSString *)path ofMediaType:(NSString *)mediaType withToken:(NSString *)token sessionID:(NSString *)sessionID success:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    NSString *urlString = [NSString stringWithFormat:@"%@&uploadTokenId=%@&ks=%@", [self.mediaServer apiURLUpload], token, sessionID];

    [[self xmlRequestManager] POST:urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        NSString *fileName = mediaType == CKIMediaCommentMediaTypeVideo ? @"videocomment.mp4" : @"audiocomment.wav";
        NSString *mimeType = mediaType == CKIMediaCommentMediaTypeVideo ? @"video/mp4" : @"audio/x-aiff";
        [formData appendPartWithFileURL:[NSURL URLWithString:path] name:@"fileData" fileName:fileName mimeType:mimeType error:nil];
    } progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        // Should get some XML back here. Might want to check it.
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void)getMediaIDForUploadedFileToken:(NSString *)token withMediaType:(NSString *)mediaType file:(NSURL *)fileURL sessionID:(NSString *)sessionID success:(void(^)(NSString *mediaUploadID))success failure:(void(^)(NSError *error))failure {
    NSString *urlString = [NSString stringWithFormat:@"%@&uploadTokenId=%@&ks=%@", [self.mediaServer apiURLAddFromUploadedFile], token, sessionID];
    NSString *mediaTypeString = ([mediaType isEqualToString:CKIMediaCommentMediaTypeVideo] ? @"1" : @"5");
    NSDictionary *parameters = @{@"mediaEntry:name": @"Media Comment", @"mediaEntry:mediaType": mediaTypeString};
    
    [[self xmlRequestManager] POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        CKIMediaFileUploadTokenParser *parser = [[CKIMediaFileUploadTokenParser alloc] initWithXMLParser:responseObject];
        [parser parseWithSuccess:^(NSString *uploadID) {
            if (success) {
                success(uploadID);
            }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
        
    } failure:^(NSURLSessionDataTask *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

#pragma mark - XML Operation Manager

- (AFHTTPSessionManager *)xmlRequestManager {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:self.baseURL];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    return manager;
}

#pragma mark - Media Server Configuration

- (void)configureMediaServerWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    
    if (self.mediaServer) {
        if (success) {
            success();
        }
        return;
    }
    
    NSString *urlString = @"api/v1/services/kaltura.json";
    [self GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.mediaServer = [[CKIMediaServer alloc] initWithInfo:responseObject];
        if (success) {
            success();
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
