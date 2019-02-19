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
