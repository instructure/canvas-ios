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
    
    

#define MAX_IMAGE_FILE_SIZE_MB .5
#define MIN_RESIZE_FACTOR .4

#import "CKAttachmentManager.h"
#import "CKAudioCommentRecorderView.h"
#import "CKActionSheetWithBlocks.h"
#import "CKAttachment.h"
#import "CKEmbeddedMediaAttachment.h"
#import "CKOverlayViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+Resize.h"
#import <AVFoundation/AVFoundation.h>
#import "EXTScope.h"
#import "UIAlertController+TechDebt.h"

@import CanvasCore;

@interface CKAttachmentManager () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIPopoverController *popoverController;
@property (strong, nonatomic) CKActionSheetWithBlocks *actionSheet;

@property (strong, nonatomic) NSString * chooseMediaLabel;
@property (strong, nonatomic) NSString * recordMediaLabel;
@property (strong, nonatomic) NSString * recordAudioLabel;

@end

@implementation CKAttachmentManager {
    __weak UIView * presentFromView;
    CGRect presentFromRect;
    UIPopoverArrowDirection permittedArrowDirections;
    NSMutableArray * mutableAttachments;
}

@synthesize imagePicker;
@synthesize popoverController;
@synthesize chooseMediaLabel, recordMediaLabel, recordAudioLabel;
@synthesize delegate;
@synthesize attachments = mutableAttachments;
@synthesize shouldApplyOverlaysToThumbs;
@synthesize viewAttachmentsOptionEnabled;
@synthesize allowedAttachmentTypes;

- (id)init
{
    self = [super init];
    if (self) {
        // Allow all attachment types by default
        allowedAttachmentTypes = CKAllowPhotoAttachments | CKAllowVideoAttachments | CKAllowAudioAttachments;
        self.recordAudioLabel = NSLocalizedString(@"Record Audio...", @"Record audio to use in a comment.");
        [self setupLabels];
        
        // Don't apply overlays by default
        self.shouldApplyOverlaysToThumbs = NO;
        
        // Don't add "View Existing Attachments..." option be default
        self.viewAttachmentsOptionEnabled = NO;
        
        mutableAttachments = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc
{
    // Make sure the popoverController and actionSheet are dismissed, or crashes could occur. See MBL-314.
    [self.popoverController dismissPopoverAnimated:YES];
    self.popoverController = nil;
    [self.actionSheet dismissWithClickedButtonIndex:self.actionSheet.cancelButtonIndex animated:NO];
    self.actionSheet = nil;
    [CKEmbeddedMediaAttachment clearAttachmentsTempFolder];
}

- (void)setAllowedAttachmentTypes:(CKAllowedAttachmentType)theAllowedAttachmentTypes
{
    allowedAttachmentTypes = theAllowedAttachmentTypes;
    
    [self setupLabels];
}

#pragma mark - Pseudo Properties

- (NSUInteger)count {
    return self.attachments.count;
}

- (void)setupLabels
{
    BOOL cameraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    self.chooseMediaLabel = NSLocalizedString(@"Choose from Library...", @"Choose an existing picture or video to use in a comment.");
    if (cameraAvailable) {
        if ((CKAllowPhotoAttachments & allowedAttachmentTypes) && (CKAllowVideoAttachments & allowedAttachmentTypes)) {
            self.recordMediaLabel = NSLocalizedString(@"Take Photo or Video...", @"Take a picture or video to use in a comment.");
        } else if (CKAllowPhotoAttachments & allowedAttachmentTypes) {
            self.recordMediaLabel = NSLocalizedString(@"Take a Photo...", @"Take a picture to use in a comment.");
        } else if (CKAllowVideoAttachments & allowedAttachmentTypes) {
            self.recordMediaLabel = NSLocalizedString(@"Take a Video...", @"Take a video to use in a comment.");
        } else {
            self.chooseMediaLabel = nil;
        }
    } else {
        self.recordMediaLabel = nil;
    }
}

- (void)clearAttachments
{
    mutableAttachments = [NSMutableArray new];
    [CKEmbeddedMediaAttachment clearAttachmentsTempFolder];
    if ([self.delegate respondsToSelector:@selector(attachmentManagerDidRemoveAllAttachments:)]) {
        [self.delegate attachmentManagerDidRemoveAllAttachments:self];
    }
}

#pragma mark - Picking an Attachment

- (void)showAttachmentPickerFromRect:(CGRect)rect
                              inView:(UIView *)view
            permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                          withSheetTitle:(NSString *)sheetTitle
{
    presentFromRect = rect;
    presentFromView = view;
    permittedArrowDirections = arrowDirections;
    [self showAttachmentPickerWithSheetTitle:sheetTitle];
}

- (void)showAttachmentPickerFromViewController:(UIViewController *)viewController withSheetTitle:(NSString *)sheetTitle
{
    self.presentFromViewController = viewController;
    [self showAttachmentPickerWithSheetTitle:sheetTitle];
}

- (void)showAttachmentPickerWithSheetTitle:(NSString *)sheetTitle
{
    self.actionSheet = [[CKActionSheetWithBlocks alloc] initWithTitle:sheetTitle];
    
    __weak CKAttachmentManager *weakSelf = self;
    [self.actionSheet addButtonWithTitle:self.chooseMediaLabel
                            handler:^{
                                [weakSelf chooseMedia];
                            }];
    
    if (self.recordMediaLabel) {
        [self.actionSheet addButtonWithTitle:self.recordMediaLabel
                                handler:^{
                                    [weakSelf recordMedia];
                                }];
    }
    
    if (CKAllowAudioAttachments & allowedAttachmentTypes) {
        [self.actionSheet addButtonWithTitle:self.recordAudioLabel
                                handler:^{
                                    [weakSelf recordAudio];
                                }];
    }
    
    if (self.viewAttachmentsOptionEnabled && mutableAttachments.count > 0) {
        [self.actionSheet addButtonWithTitle:NSLocalizedString(@"Existing Attachments...", nil)
                                handler:^{
                                    [weakSelf.delegate showAttachmentsForAttachmentManager:weakSelf];
                                }];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.actionSheet showFromRect:presentFromRect
                           inView:presentFromView
                         animated:YES];
    } else{
        
        [self.actionSheet addCancelButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button title")];
        
        self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        if (self.presentFromViewController.tabBarController) {
            [self.actionSheet showFromTabBar:self.presentFromViewController.tabBarController.tabBar];
        }
        else {
            [self.actionSheet showInView:self.presentFromViewController.view];
        }
    }
}

- (void)chooseMedia
{
    [self presentImagePickerWithSource:UIImagePickerControllerSourceTypePhotoLibrary fullScreen:NO];
}

- (void)recordMedia
{
    [self presentImagePickerWithSource:UIImagePickerControllerSourceTypeCamera fullScreen:YES];
}

- (void)recordAudio 
{
    @weakify(self);
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *doneButtonTitle = NSLocalizedString(@"Use", @"button for using the recorded audio");
            AudioRecorderViewController *recorder = [AudioRecorderViewController presentFrom:self.presentFromViewController completeButtonTitle:doneButtonTitle];
            
            @weakify(recorder);
            [recorder setCancelButtonTapped:^{
                @strongify(recorder);
                [recorder dismissViewControllerAnimated:true completion:nil];
            }];
            
            [recorder setDidFinishRecordingAudioFile:^(NSURL *url) {
                @strongify(recorder);
                @strongify(self);
                [self finishedRecordingAudioFile:url];
                [recorder dismissViewControllerAnimated:true completion:nil];
            }];
        });
    }];
}

- (void)finishedRecordingAudioFile:(NSURL *)pathToAudio
{
    CKAttachmentMediaType mediaTypeToUse = CKAttachmentMediaTypeAudio;

    if (!pathToAudio || mediaTypeToUse == CKAttachmentMediaTypeUnknown) {
        // This means that they tried to submit a comment without an audio attachment
        [UIAlertController showAlertWithTitle:NSLocalizedString(@"No Recorded Audio", @"Title for attempting submission without a comment") message:NSLocalizedString(@"No audio was recorded.", @"Message for attempting submission without a comment")];
        
        return;
    }
    
    CKEmbeddedMediaAttachment * mediaAttachment = [CKEmbeddedMediaAttachment new];
    mediaAttachment.type = CKAttachmentMediaTypeAudio;
    mediaAttachment.url = pathToAudio;
    [mediaAttachment generateThumbnailAndApplyOverlay:self.shouldApplyOverlaysToThumbs];
    [mutableAttachments addObject:mediaAttachment];
    
    [self.delegate attachmentManager:self didAddAttachmentAtIndex:mutableAttachments.count - 1];
}

- (void)presentImagePickerWithSource:(UIImagePickerControllerSourceType)sourceType fullScreen:(BOOL)fullScreen
{
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.navigationBar.barStyle = UIBarStyleBlack;
    self.imagePicker.navigationBar.translucent = YES;
    [self.imagePicker.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    self.imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    
    self.imagePicker.delegate = self;
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        self.imagePicker.sourceType = sourceType;
    } else {
        NSLog(@"Do we have a problem?");
    }
    
    NSArray *allowedMediaTypes;
    if ((CKAllowPhotoAttachments & allowedAttachmentTypes) && (CKAllowVideoAttachments & allowedAttachmentTypes)) {
        allowedMediaTypes = @[(NSString *) kUTTypeImage,
                             (NSString *) kUTTypeMovie];
    } else if (CKAllowVideoAttachments & allowedAttachmentTypes) {
        allowedMediaTypes = @[(NSString *) kUTTypeMovie];
    } else if (CKAllowPhotoAttachments & allowedAttachmentTypes) {
        allowedMediaTypes = @[(NSString *) kUTTypeImage];
    } else {
        NSLog(@"This option should never be presented to the user");
    }
    
    self.imagePicker.mediaTypes = allowedMediaTypes;
    
    self.imagePicker.allowsEditing = NO;
    
    if (!fullScreen && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePicker];
        [self.popoverController presentPopoverFromRect:presentFromRect
                                                inView:presentFromView
                              permittedArrowDirections:permittedArrowDirections
                                              animated:YES];
    } else{
        [self.presentFromViewController presentViewController:self.imagePicker animated:YES completion:nil];
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    self.imagePicker.navigationBar.barStyle = UIBarStyleBlack;
    self.imagePicker.navigationBar.translucent = YES;
    [self.imagePicker.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]];
    self.imagePicker.navigationBar.tintColor = [UIColor whiteColor];
    
    // Keeps the status bar black when the imagepicker tries to change it.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

#pragma - mark UIImagePickerController delegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    CKEmbeddedMediaAttachment * mediaAttachment = [CKEmbeddedMediaAttachment new];
    
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        
        mediaAttachment.type = CKAttachmentMediaTypeImage;
        if (info[UIImagePickerControllerEditedImage]) {
            mediaAttachment.image = info[UIImagePickerControllerEditedImage];
        } else {
            mediaAttachment.image = info[UIImagePickerControllerOriginalImage];
        }
        
        mediaAttachment.image = [self compressImage:mediaAttachment.image];
        mediaAttachment.image = [self scaleAndRotateImage:mediaAttachment.image];
        
    } else if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie]) {
        mediaAttachment.type = CKAttachmentMediaTypeVideo;
        mediaAttachment.url = info[UIImagePickerControllerMediaURL];
    } else {
        NSLog(@"UIImagePickerController returned an unknown attachment type");
        return;
    }
    
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    } else {
        [self.presentFromViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [mediaAttachment generateThumbnailAndApplyOverlay:self.shouldApplyOverlaysToThumbs];
    [mutableAttachments addObject:mediaAttachment];
    
    [self.delegate attachmentManager:self didAddAttachmentAtIndex:mutableAttachments.count - 1];
}

- (UIImage *)compressImage:(UIImage *)image {
    NSData  *imageData    = UIImagePNGRepresentation(image);
    double   factor       = 1.0;
    double   adjustment   = 1.0 / sqrt(2.0);  // or use 0.8 or whatever you want
    CGSize   size         = image.size;
    CGSize   currentSize  = size;
    UIImage *currentImage = image;
    
    int maxFileSizeInMB = MAX_IMAGE_FILE_SIZE_MB*1024*1024;
    
    while ([imageData length] > maxFileSizeInMB && factor > MIN_RESIZE_FACTOR)
    {
        factor      *= adjustment;
        currentSize  = CGSizeMake(roundf(size.width * factor), roundf(size.height * factor));
        currentImage = [image resizedImage:currentSize interpolationQuality:kCGInterpolationHigh];
        imageData    = UIImagePNGRepresentation(currentImage);
    }

    return [[UIImage alloc] initWithData:imageData];
}

- (UIImage *)scaleAndRotateImage:(UIImage *)image {
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    int kMaxResolution = MAX(roundf(width), roundf(height)); // Currently not resizing
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
    } else {
        [self.presentFromViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return mutableAttachments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttachmentCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"AttachmentCell"];
    }
    
    CKEmbeddedMediaAttachment *attachment = mutableAttachments[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Attachment %d", @"label for an attachment"), indexPath.row + 1];
    NSString *detailText;
    switch (attachment.type) {
        case CKAttachmentMediaTypeAudio:
            detailText = NSLocalizedString(@"Audio", @"Audio file type");
            break;
        case CKAttachmentMediaTypeVideo:
            detailText = NSLocalizedString(@"Video", @"Video file type");
            break;
        case CKAttachmentMediaTypeImage:
            detailText = NSLocalizedString(@"Image", @"Image file type");
            break;
        default:
            detailText = NSLocalizedString(@"Unknown", @"Unknown file type");
            break;
    }
    cell.detailTextLabel.text = detailText;
    cell.imageView.image = attachment.thumb;
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [mutableAttachments removeObjectAtIndex:indexPath.row];
        if ([self.delegate respondsToSelector:@selector(attachmentManager:didRemoveAttachmentAtIndex:)]) {
            [self.delegate attachmentManager:self didRemoveAttachmentAtIndex:indexPath.row];
        }
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
    }
}

@end
