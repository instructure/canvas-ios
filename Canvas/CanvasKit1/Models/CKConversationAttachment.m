
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
    
    

#import "CKConversationAttachment.h"

@implementation CKConversationAttachment

- (id)initWithInfo:(NSDictionary *)info {
    self = [super initWithInfo:info];
    if (self) {
        
        self.mediaId = info[@"media_id"];
        if (self.filename == nil) {
            self.filename = @"conversation_attachment";
        }
        
        if ([self.contentType isEqualToString:CKAttachmentMediaTypeVideoString]) {
            self.mediaType = CKAttachmentMediaTypeVideo;
        }
        else if ([self.contentType isEqualToString:CKAttachmentMediaTypeAudioString]) {
            self.mediaType = CKAttachmentMediaTypeAudio;
        }
        else {
            self.mediaType = CKAttachmentMediaTypeUnknown;
        }
    }
    return self;
}

@end
