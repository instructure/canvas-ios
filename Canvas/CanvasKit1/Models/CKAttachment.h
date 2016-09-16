//
//  CKAttachment.h
//  CanvasKit
//
//  Created by Zach Wily on 5/17/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
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
