//
//  CKConversationAttachment.m
//  CanvasKit
//
//  Created by BJ Homer on 10/5/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
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
