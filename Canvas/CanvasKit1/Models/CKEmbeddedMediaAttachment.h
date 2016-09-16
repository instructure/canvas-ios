//
//  CKEmbeddedMediaAttachment.h
//  CanvasKit
//
//  Created by Stephen Lottermoser on 4/4/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CKAttachment.h"

@interface CKEmbeddedMediaAttachment : NSObject

@property (nonatomic) uint64_t attachmentId;
@property (nonatomic) CKAttachmentMediaType type;
@property (strong, nonatomic) UIImage * image;
@property (strong, nonatomic) UIImage * thumb;
@property (strong, nonatomic) NSURL * urlForThumb;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) NSString *mediaId;
@property (strong, nonatomic) NSString *stringForEmbedding;

/**
 * Generates a thumbnail for the media attachment.
 * @param applyOverlay a BOOL indicating whether or not to apply an overlay similar
 *                     to the one used in Messages.app over the thumbnail.
 */
- (void)generateThumbnailAndApplyOverlay:(BOOL)applyOverlay;

// Call this to remove the attachments temp folder and everything in it
// (thumbs, images, video thumbs, etc)
+ (void)clearAttachmentsTempFolder;

@end
