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
    
    

#import "CKEmbeddedMediaAttachment.h"
#import "NSFileManager+CKAdditions.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+CanvasKit1.h"

@implementation CKEmbeddedMediaAttachment

@synthesize attachmentId, type, image, thumb, urlForThumb, url, mediaId, stringForEmbedding;

- (void)generateThumbnailAndApplyOverlay:(BOOL)applyOverlay {
    if (self.type == CKAttachmentMediaTypeVideo) {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:self.url options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef frame0Image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        self.thumb = [[UIImage alloc] initWithCGImage:frame0Image];
        CGImageRelease(frame0Image);
        
    } else if (self.type == CKAttachmentMediaTypeAudio) {
        // set default audio thumbnail
        self.thumb = [UIImage canvasKit1ImageNamed:@"sound_thumb"];
    } else if (self.type == CKAttachmentMediaTypeImage) {
        self.thumb = self.image;
        // Save the image to the file system
        [self saveImageToFileSystem];
    } else {
        NSAssert(FALSE, @"No thumnail generation code found for this type off attachment. Please implement.");
    }
    
    [self resizeThumbAndApplyOverlay:applyOverlay];
    [self generatePathForThumbnail];
}

- (void)generatePathForThumbnail
{
    // Save the image to the filesystem to display the thumbnail elsewhere, like the CKRichTextEditor's webview
    NSData *imageData = UIImagePNGRepresentation(self.thumb);
    NSURL *tempURL = attachmentsTempFolder();
    NSString *imageSaveName = [NSString stringWithFormat:@"%f-thumb.png", [[NSDate date] timeIntervalSince1970]];
    NSURL *savePath = [tempURL URLByAppendingPathComponent:imageSaveName];
    BOOL result = [imageData writeToURL:savePath atomically:YES];
    if (!result) {
        NSLog(@"Saving the file failed. We should use some default image instead");
    } else {
        self.urlForThumb = savePath;
    }
}

- (void)resizeThumbAndApplyOverlay:(BOOL)applyOverlay
{
    UIImage *overlayImage = [UIImage canvasKit1ImageNamed:@"glow"];
    UIImage *overlay = [overlayImage resizableImageWithCapInsets:UIEdgeInsetsMake(12.0, 12.0, 12.0, 12.0)];
    
    UIImage *videoOverlay;
    if (self.type == CKAttachmentMediaTypeVideo) {
        videoOverlay = [UIImage canvasKit1ImageNamed:@"video_play"];
    }
    
    // glow.png is 85 pixels wide. Right now all image thumbnails are resized to this width.
    CGSize newSize = CGSizeMake(overlayImage.size.width, ceilf(overlayImage.size.width * (self.thumb.size.height / self.thumb.size.width)));
    UIGraphicsBeginImageContextWithOptions( newSize, YES, [[UIScreen mainScreen] scale] );
    
    // Use existing opacity as is
    [self.thumb drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    
    // Always add the video play icon for video thumbs
    if (self.type == CKAttachmentMediaTypeVideo) {
        [videoOverlay drawInRect:CGRectMake((newSize.width / 2) - (videoOverlay.size.width / 2), (newSize.height / 2) - (videoOverlay.size.height / 2), videoOverlay.size.width, videoOverlay.size.height)];
    }
    
    if (applyOverlay) {
        // Add overlay
        [overlay drawInRect:CGRectMake(0.0, 0, newSize.width, newSize.height + 1.0)];
    }    
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    self.thumb = newImage;
}

- (void)saveImageToFileSystem
{
    // Save the image to the filesystem
    NSData *imageData = UIImageJPEGRepresentation(self.image, 1);
    NSURL * tempURL = attachmentsTempFolder();
    NSString *imageSaveName = [NSString stringWithFormat:@"%f-original.png", [[NSDate date] timeIntervalSince1970]];
    NSURL* savePath = [tempURL URLByAppendingPathComponent:imageSaveName];
    BOOL result = [imageData writeToURL:savePath atomically:YES];
    if (!result) {
        NSLog(@"Saving the edited image failed. We should notify the user and have them retake the pic.");
    } else {
        self.url = savePath;
    }
}

+ (void)clearAttachmentsTempFolder
{
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtURL:attachmentsTempFolder() error:&error];
    if (error) {
        NSLog(@"Error removing attachment folder: %@", [error localizedDescription]);
    }
}

static NSURL *attachmentsTempFolder() {
    NSFileManager *fileManager = [NSFileManager new];
    NSURL * tempURL = [NSURL fileURLWithPath:NSTemporaryDirectory()];
    NSURL *tempFolder = [tempURL URLByAppendingPathComponent:@"AttachmentsTempFolder"];
    [fileManager createDirectoryAtURL:tempFolder withIntermediateDirectories:YES attributes:nil error:NULL];
    
    return tempFolder;
}

@end
