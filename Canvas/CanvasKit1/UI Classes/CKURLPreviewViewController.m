//
//  CKURLPreviewViewController.m
//  CanvasKit
//
//  Created by BJ Homer on 4/2/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import "CKURLPreviewViewController.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>


@interface PreviewItem : NSObject <QLPreviewItem>

@end

@implementation PreviewItem
@synthesize previewItemTitle, previewItemURL;

+ (PreviewItem *)previewItemWithTitle:(NSString *)title URL:(NSURL *)url
{
    PreviewItem *previewItem = [PreviewItem new];
    previewItem->previewItemTitle = title;
    previewItem->previewItemURL = url;
    return previewItem;
}

@end


@interface CKURLPreviewViewController () <QLPreviewControllerDataSource>
@property NSURL *tempImageURL;
@end


@implementation CKURLPreviewViewController 
@synthesize title;
@synthesize modalBarStyle;

- (id)init {
    self = [super init];
    if (self) {
        self.dataSource = self;
    }
    return self;
}

const CGFloat maxSize = 1536;

- (void)setUrl:(NSURL *)url {
    _url = url;
    
    NSString *uti;
    [url getResourceValue:&uti forKey:NSURLTypeIdentifierKey error:NULL];
    
    if (UTTypeConformsTo((__bridge CFStringRef)uti, kUTTypeImage)) {
        // check to see if image is too large
        CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
        
        if (imageSource) {
            CGFloat width = 0.0f;
            CGFloat height = 0.0f;
            CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
            if (imageProperties) {
                CFNumberRef widthNum  = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelWidth);
                if (widthNum) {
                    CFNumberGetValue(widthNum, kCFNumberFloatType, &width);
                }
                
                CFNumberRef heightNum = CFDictionaryGetValue(imageProperties, kCGImagePropertyPixelHeight);
                if (heightNum) {
                    CFNumberGetValue(heightNum, kCFNumberFloatType, &height);
                }
                
                CFRelease(imageProperties);
            }
            
            if (width > maxSize || height > maxSize) {
                // resize the image
                CFDictionaryRef thumbnailOptions = (__bridge CFDictionaryRef)@{
                    (id)kCGImageSourceCreateThumbnailWithTransform : @YES,
                    (id)kCGImageSourceCreateThumbnailFromImageAlways : @YES,
                    (id)kCGImageSourceThumbnailMaxPixelSize : @(maxSize)
                };
                
                CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, thumbnailOptions);
                UIImage *image = [UIImage imageWithCGImage:imageRef];
                if (!_tempImageURL) {
                    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:url.lastPathComponent];
                    _tempImageURL = [NSURL fileURLWithPath:tempPath];
                }
                _url = _tempImageURL;
                [UIImagePNGRepresentation(image) writeToFile:_url.path atomically:YES];
                
                CGImageRelease(imageRef);
            }
            CFRelease(imageSource);
        }
        
    }
}

- (void)dealloc {
    // Remove temp file. This will be done on program exit, but we can
    // free the space now
    if (_tempImageURL) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:_tempImageURL.path]) {
            [fileManager removeItemAtPath:_tempImageURL.path error:nil];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)viewDidLayoutSubviews{
    if (modalBarStyle != UIBarStyleDefault) {
        UINavigationBar *bar = nil;
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UINavigationBar class]]) {
                [((UINavigationBar *)view) setHidden:YES];
                bar = (id)view;
                break;
            }
        }
        bar.barStyle = modalBarStyle;
    }
}

- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
    return 1;
}

- (id<QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index {
    if (self.title) {
        return [PreviewItem previewItemWithTitle:self.title URL:self.url];
    } else {
        return self.url;
    }
}

@end
