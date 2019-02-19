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
    
    

#import "CKAttachment.h"
#import "CKSubmissionAttempt.h"
#import "CKAssignment.h"
#import "CKCanvasAPI.h"
#import "NSString+CKAdditions.h"
#import "CKMediaServer.h"
#import "NSDictionary+CKAdditions.h"

NSString *CKAttachmentMediaTypeUnknownString = @"video/mp4"; // Default to video for unknown type
NSString *CKAttachmentMediaTypeVideoString = @"video/mp4";
NSString *CKAttachmentMediaTypeAudioString = @"audio/mp4";

@interface CKAttachment () {
    NSDictionary *raw;
}

@end

@implementation CKAttachment

@synthesize ident, displayName, filename, contentType, directDownloadURL, mediaId, type, mediaType, internalIdent;
@synthesize fileSize = _fileSize;

- (id)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        self.ident = [[info objectForKeyCheckingNull:@"id"] unsignedLongLongValue];

        raw = info;
        self.displayName = [info objectForKeyCheckingNull:@"display_name"];
        self.filename = [[info objectForKeyCheckingNull:@"filename"] stringByRemovingPercentEncoding];
        if (!self.displayName) self.displayName = self.filename;
        self.contentType = [info objectForKeyCheckingNull:@"content-type"];
        self.directDownloadURL = [NSURL URLWithString:[info objectForKeyCheckingNull:@"url"]];
        _fileSize = [[info objectForKeyCheckingNull:@"size"] unsignedLongLongValue];
        
        _locked = [[info objectForKeyCheckingNull:@"locked"] boolValue];
        _lockedForUser = [[info objectForKeyCheckingNull:@"locked_for_user"] boolValue];
        
        _contentLock = [[CKContentLock alloc] initWithInfo:info];
    }
    return self;
}


- (id)copyWithZone:(NSZone *)zone {
    CKAttachment *newAttachment = [[[self class] alloc] init];
    
    newAttachment->ident = ident;
    newAttachment->internalIdent = internalIdent;
    newAttachment->displayName = displayName;
    newAttachment->filename = filename;
    newAttachment->_fileSize = _fileSize;
    newAttachment->contentType = contentType;
    newAttachment->_locked = _locked;
    newAttachment->directDownloadURL = directDownloadURL;
    newAttachment->mediaId = mediaId;
    newAttachment->type = type;
    newAttachment->mediaType = mediaType;
    
    return newAttachment;
}


- (int)cacheVersion
{
    return 1;
}

- (NSString *)internalIdent
{
    if (internalIdent == nil) {
        if (ident > 0) {
            internalIdent = [NSString stringWithFormat:@"%qu", self.ident];
        }
        else {
            NSArray *stack = [NSThread callStackSymbols];
            NSLog(@"Warning: CKAttachment.internalIdent requested without adequate information. %@", stack);
            internalIdent = [NSString stringWithFormat:@"%@", self.filename];
        }
    }
    return internalIdent;
}

- (NSString *)description
{
    return [[self dictionaryValue] description];
}


- (BOOL)isMedia
{
    return self.mediaId != nil;
}

- (BOOL)isImage
{
    if ([self.contentType isEqualToString:@"image/png"]) {
        return YES;
    }
    else if ([self.contentType isEqualToString:@"image/jpeg"]) {
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)isStreamingItem
{
    return [self isMedia];
}

- (NSString *)mediaTypeString
{
    if (self.mediaId && self.mediaType == CKAttachmentMediaTypeAudio) {
        return CKAttachmentMediaTypeAudioString;
    }
    if (self.mediaId && self.mediaType == CKAttachmentMediaTypeVideo) {
        return CKAttachmentMediaTypeVideoString;
    }
    if (self.mediaId) {
        return CKAttachmentMediaTypeUnknownString; // this currently defaults to video
    }
    return nil;
}

+ (NSArray *)propertiesToExcludeFromEqualityComparison {
    return @[ @"internalIdent" ];
}

- (NSUInteger)hash
{
    return [self.internalIdent hash];
}

- (NSURL *)cacheURL
{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = cachePaths[0];
    NSString *path = [NSString stringWithFormat:@"%@/attachments/%i/%@",
                      cachePath,
                      [self cacheVersion],
                      self.internalIdent];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", path, self.filename];
    return [NSURL fileURLWithPath:fullPath];
}

- (NSURL *)thumbnailCacheURL
{
    return [NSURL fileURLWithPath:[[[self cacheURL] path] stringByAppendingString:@"-thumbnail"]];
}

// TODO: move this to an NSFileManager additions file and make it generic: relativePathFromPath:toPath:
- (NSString *)relativePathToResourcesDir
{
    // Create empty relativeURLString
    NSMutableString *relativePathString = [NSMutableString stringWithString:@""];
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *cachePath = [[self cacheURL] path];
    
    // Remove the filename
    cachePath = [cachePath stringByDeletingLastPathComponent];
    
    BOOL stillLooking = YES;
    
    NSString *immutableRelativePathString = nil;
    int trips = 0;
    while (stillLooking) {
        // Pop off lastPathComponent and append ../
        cachePath = [cachePath stringByDeletingLastPathComponent];
        [relativePathString appendString:@"../"];
        
        // TODO: handle the case that Apple changes where the resourceURL lives
        // Compare current path to [[[NSBundle mainBundle] resourcePath]
        if ([cachePath isEqualToString:[resourcePath stringByDeletingLastPathComponent]]) {
            // If it matches, append the bundlename (SpeedGrader.app) exit loop
            immutableRelativePathString = [relativePathString stringByAppendingPathComponent:[resourcePath lastPathComponent]];
            stillLooking = NO;
        }
        if (trips >= 50) {
            NSLog(@"The path search has gone too far and is assumed to have failed. Avoiding potential infinite loop.");
            stillLooking = NO;
        }
        trips++;
    }
    
    return immutableRelativePathString;
}


- (NSURL *)thumbnailDirectDownloadURL
{
    // Can be overridden by subclasses
    return nil;
}

- (NSDictionary *)dictionaryValue
{
    return @{@"ident": self.internalIdent,
            @"displayName": (self.displayName ?: @""),
            @"isMedia": @([self isMedia]),
            @"mediaType": ([self isMedia] ? [self mediaTypeString] : @""),
            @"mediaId": ([self isMedia] ? self.mediaId : @""),
            @"directURL": ([[self directDownloadURL] absoluteString] ?: @""),
            @"thumbnailURL": ([[self thumbnailCacheURL] absoluteString] ?: @"")};
}

@end
