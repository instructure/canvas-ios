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
    
    

#import "CKMediaComment.h"
#import "CKMediaServer.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKMediaComment

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super initWithInfo:info];
    if (self) {
        self.mediaId = [info objectForKeyCheckingNull:@"media_id"];
        
        self.contentType = [info objectForKeyCheckingNull:@"content-type"];
        
        if ([self.contentType isEqualToString:CKAttachmentMediaTypeVideoString]) {
            self.mediaType = CKAttachmentMediaTypeVideo;
        }
        else if ([self.contentType isEqualToString:CKAttachmentMediaTypeAudioString]) {
            self.mediaType = CKAttachmentMediaTypeAudio;
        }
        else {
            self.mediaType = CKAttachmentMediaTypeUnknown;
        }
        
        if (!self.displayName) {
            self.displayName = NSLocalizedString(@"Media comment", @"The name for a video or audio response to something");
        }
        if (!self.filename) {
            self.filename = NSLocalizedString(@"unknown", @"When we don't know the name of a file, we display this");
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    CKMediaComment *comment = [super copyWithZone:zone];
    return comment;
}

- (NSURL *)cacheURL {
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = cachePaths[0];
    NSString *path = [NSString stringWithFormat:@"%@/attachments/%i/media/%@",
                      cachePath,
                      [self cacheVersion],
                      self.mediaId];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", path, self.filename];
    return [NSURL fileURLWithPath:fullPath];
}


- (NSString *)internalIdent {
    if (self.mediaId) {
        return self.mediaId;
    }
    else {
        return [super internalIdent];
    }
}

@end
