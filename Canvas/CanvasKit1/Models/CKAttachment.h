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

extern NSString *CKAttachmentMediaTypeUnknownString;
extern NSString *CKAttachmentMediaTypeVideoString;
extern NSString *CKAttachmentMediaTypeAudioString;

@class CKAssignment, CKSubmissionAttempt, CKMediaServer, CKContentLock;

@interface CKAttachment : CKModelObject <NSCopying>

@property (nonatomic, assign) uint64_t ident;
@property (nonatomic, strong) NSString *internalIdent;
@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, assign) uint64_t fileSize;
@property (nonatomic, strong) NSString *contentType;
@property (assign, getter = isLocked) BOOL locked;
@property (assign, getter = isLockedForUser) BOOL lockedForUser;
@property (nonatomic, strong) NSURL *directDownloadURL;
@property (nonatomic, strong) NSString *mediaId;
@property (nonatomic, assign) CKAttachmentType type;
@property (nonatomic, assign) CKAttachmentMediaType mediaType;

@property (readonly) CKContentLock *contentLock;

- (id)initWithInfo:(NSDictionary *)info;

- (int)cacheVersion;

- (BOOL)isMedia;
- (BOOL)isImage;
- (BOOL)isStreamingItem;

- (NSURL *)cacheURL;
- (NSURL *)thumbnailCacheURL;
- (NSString *)relativePathToResourcesDir;

- (NSString *)mediaTypeString;

- (NSDictionary *)dictionaryValue;

@end
