//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
