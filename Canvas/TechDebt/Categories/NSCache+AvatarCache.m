//
//  NSCache+AvatarCache.m
//  iCanvas
//
//  Created by derrick on 5/1/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "NSCache+AvatarCache.h"

@implementation NSCache (AvatarCache)
+ (instancetype)sharedAvatarCache
{
    static NSCache *cache;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[NSCache alloc] init];
    });
    
    return cache;
}

- (UIImage *)cachedAvatarForURL:(NSURL *)url
{
    NSPurgeableData *data = [self objectForKey:url];
    if (![data beginContentAccess]) {
        return nil;
    }
    
    UIImage *image = [[UIImage alloc] initWithData:data];
    [data endContentAccess];
    return image;
}

- (void)cacheAvatar:(UIImage *)avatar forURL:(NSURL *)url
{
    NSPurgeableData *purgable = [[NSPurgeableData alloc] initWithData:UIImagePNGRepresentation(avatar)];
    [self setObject:purgable forKey:url];
    [purgable endContentAccess];
}

@end
