//
//  NSCache+AvatarCache.h
//  iCanvas
//
//  Created by derrick on 5/1/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSCache (AvatarCache)
+ (instancetype)sharedAvatarCache;

- (UIImage *)cachedAvatarForURL:(NSURL *)url;
- (void)cacheAvatar:(UIImage *)avatar forURL:(NSURL *)url;

@end
