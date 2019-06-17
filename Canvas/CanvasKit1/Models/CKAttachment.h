//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
    
    

#import <Foundation/Foundation.h>
#import "CKModelObject.h"

typedef enum {
    CKAttachmentTypeDefault,
    CKAttachmentTypeInline
} CKAttachmentType;

typedef enum {
    CKAttachmentMediaTypeUnknown,
    CKAttachmentMediaTypeVideo,
    CKAttachmentMediaTypeAudio,
    CKAttachmentMediaTypeImage
} CKAttachmentMediaType;

extern NSString * _Nonnull CKAttachmentMediaTypeUnknownString;
extern NSString * _Nonnull CKAttachmentMediaTypeVideoString;
extern NSString * _Nonnull CKAttachmentMediaTypeAudioString;

@class CKAssignment, CKSubmissionAttempt, CKMediaServer, CKContentLock;

@interface CKAttachment : CKModelObject <NSCopying>

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, strong, nonnull) NSString *internalIdent;
@property (nonatomic, strong, nonnull) NSString *displayName;
@property (nonatomic, strong, nonnull) NSString *filename;
@property (nonatomic, assign) uint64_t fileSize;
@property (nonatomic, strong, nonnull) NSString *contentType;
@property (assign, getter = isLocked) BOOL locked;
@property (assign, getter = isLockedForUser) BOOL lockedForUser;
@property (nonatomic, strong, nonnull) NSURL *directDownloadURL;
@property (nonatomic, strong, nullable) NSString *mediaId;
@property (nonatomic, assign) CKAttachmentType type;
@property (nonatomic, assign) CKAttachmentMediaType mediaType;
@property (nullable, nonatomic, strong) NSString *avatarToken;

@property (readonly, nullable) CKContentLock *contentLock;

- (nullable id)initWithInfo:(nullable NSDictionary *)info;

- (int)cacheVersion;

- (BOOL)isMedia;
- (BOOL)isImage;
- (BOOL)isStreamingItem;

- (nonnull NSURL *)cacheURL;
- (nonnull NSURL *)thumbnailCacheURL;
- (nonnull NSString *)relativePathToResourcesDir;

- (nullable NSString *)mediaTypeString;

- (nonnull NSDictionary *)dictionaryValue;

@end
