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
    
    

#import "CKRemoteImageView.h"

@implementation CKRemoteImageView {
    id observer;
}
@synthesize imageCache = _imageCache;
@synthesize imageURL = _imageURL;
@synthesize afterLoadingBlock;


- (void)setImageURL:(NSURL *)imageURL {
    if ([_imageURL isEqual:imageURL]) {
        return;
    }
    _imageURL = imageURL;    
    
    self.image = nil;
    if (observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
        observer = nil;
    }
    
    if (self.imageCache) {
        [self loadImage];
    }
}

- (void)setImageCache:(NSCache *)imageCache {
    BOOL cacheWasNil = _imageCache == nil;
    _imageCache = imageCache;
    
    if (_imageCache && cacheWasNil && self.imageURL) {
        [self loadImage];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    if (newWindow && self.image == nil) {
        [self loadImage];
    }
}

- (void)loadImage {
    static NSString * CKLoadedImageNotification = @"CKLoadedImageNotification";

    static NSOperationQueue *loadingQueue = nil;
    if (!loadingQueue) {
        loadingQueue = [NSOperationQueue new];
        loadingQueue.maxConcurrentOperationCount = 8;
    }
    
    NSNotificationCenter *noteCenter = [NSNotificationCenter defaultCenter];
    
    NSURL *url = self.imageURL;
    
    NSPurgeableData *data = [_imageCache objectForKey:url];
    
    if (![data beginContentAccess]) {
        // Request it!
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                NSPurgeableData *purgeableData = [[NSPurgeableData alloc] initWithData:data];
                [_imageCache setObject:purgeableData forKey:url];
                [noteCenter postNotificationName:CKLoadedImageNotification object:url];
                [purgeableData endContentAccess];
            }
        }] resume];
        data = [NSPurgeableData new];
        [_imageCache setObject:data forKey:url];
    }
    
    if ([data length] == 0) {
        // Already being requested; just watch for the notification
        __weak CKRemoteImageView *weakSelf = self;
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:CKLoadedImageNotification
                                                                     object:nil
                                                                      queue:[NSOperationQueue mainQueue]
                                                                 usingBlock:
                    ^(NSNotification *note) {
                        if ([[note object] isEqual:url] == NO) {
                            return;
                        }
                        
                        CKRemoteImageView *strongSelf = weakSelf;
                        if (strongSelf) {
                            [strongSelf loadImage];
                            [[NSNotificationCenter defaultCenter] removeObserver:strongSelf->observer];
                            strongSelf->observer = nil;
                        }
                    }];
    }
    else {
        UIImage *avatar = [UIImage imageWithData:data];
        self.image = avatar;
        if (afterLoadingBlock) {
            afterLoadingBlock();
        }
    }
    [data endContentAccess];
}

- (void)dealloc {
    if (observer) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

- (void)reloadImage {
    [_imageCache removeObjectForKey:_imageURL];
    [self loadImage];
}

@end
