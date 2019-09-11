//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
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

#import <Foundation/Foundation.h>
#import <CanvasKit1/CKEnrollment.h>
#import <CanvasKit1/CKDiscussionTopic.h>
#import <CanvasKit1/CKAttachment.h>

@class CKFolder, CKPaginationInfo, CKUser, CKCanvasURLConnection;


// The isFinalValue argument (the BOOL) will be false if this is cached data being returned,
// and real data is being loaded. This can happen when the cached data is expired. We
// still want to show it while the real data is being loaded. So the block can actually
// be called multiple times.
typedef void (^CKSimpleBlock)(NSError *error, BOOL isFinalValue);
typedef void (^CKObjectBlock)(NSError *error, BOOL isFinalValue, id object);
typedef void (^CKArrayBlock)(NSError *error, BOOL isFinalValue, NSArray *array);
typedef void (^CKDictionaryBlock)(NSError *error, BOOL isFinalValue, NSDictionary *dictionary);
typedef void (^CKURLBlock)(NSError *error, BOOL isFinalValue, NSURL *url);
typedef void (^CKStringBlock)(NSError *error, BOOL isFinalValue, NSString * aString);
typedef void (^CKUploadTargetBlock)(NSError *error, BOOL isFinalValue, NSURL *uploadURL, NSDictionary *uploadParams);
typedef void (^CKAttachmentBlock)(NSError *error, BOOL isFinalValue, CKAttachment *attachment);

// Paged results should not be cached, because we always need the pagination
// info, which is not stored in the local cache. Thus we don't bother with an
// 'isFinalValue' BOOL, since it should always be the final value.
typedef void (^CKPagedArrayBlock)(NSError *error, NSArray *theArray, CKPaginationInfo *pagination);

extern NSString * const CKCanvasUserWasUpdatedNotification;

extern NSString * const CKUserAgentKey;

extern NSString * const CKCanvasUserInfoKey;
extern NSString * const CKCanvasAccessTokenKey;
extern NSString * const CKCanvasUserIDKey;
extern NSString * const CKCanvasUserNameKey;
extern NSString * const CKCanvasHostnameKey;
extern NSString * const CKCanvasAPIProtocolKey;
extern NSString * const CKCanvasUserInfoVersionKey;

@interface CKCanvasAPI : NSObject

@property (nonatomic, strong) NSString *username DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSString *password DEPRECATED_ATTRIBUTE;
@property (nonatomic, strong) NSString *hostname;
@property (nonatomic, strong) NSString *authString;
@property (nonatomic, strong) NSString *actAsId;
@property (nonatomic, strong) NSString *clientId;
@property (nonatomic, strong) NSString *clientSecret;
@property (nonatomic, strong) NSString *apiProtocol;
@property (nonatomic, strong) CKUser *user;
@property (nonatomic, assign, getter=isVerified) BOOL verified;
@property (nonatomic, strong) CKMediaServer *mediaServer;

@property (assign) int itemsPerPage;

@property (copy) NSString *accessToken;

// ow my eyes! I just don't want to refactor all the methods below to plumb this in yet...
@property (nonatomic, assign) BOOL refreshCacheOnNextRequest;

- (id)init;

#pragma mark - User Info
- (void)getUserProfileWithBlock:(CKSimpleBlock)block;
- (void)postAvatarNamed:(NSString *)name fileURL:(NSURL *)fileURL block:(CKAttachmentBlock)block;
- (void)updateLoggedInUserAvatarWithToken:(NSString *)token block:(CKDictionaryBlock)block;


#pragma mark - Submissions
#pragma mark (Viewing)
- (CKCanvasURLConnection *)getURLForAttachment:(CKAttachment *)attachment block:(CKURLBlock)block;
- (CKCanvasURLConnection *)downloadAttachment:(CKAttachment *)attachment progressBlock:(void (^)(float progress))progressBlock completionBlock:(CKURLBlock)completionBlock;



#pragma mark - Media Comments
- (void)getMediaServerConfigurationWithBlock:(CKSimpleBlock)block;


#pragma mark - Files
- (void)getFileWithId:(uint64_t)fileIdent block:(CKObjectBlock)block;
- (void)uploadFiles:(NSArray *)fileURLs toFolder:(CKFolder *)folder progressBlock:(void (^)(float progress))progressBlock completionBlock:(CKArrayBlock)block;


@end
