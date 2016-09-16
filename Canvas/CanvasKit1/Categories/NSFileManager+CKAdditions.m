//
//  NSFileManager+CKAdditions.m
//  CanvasKit
//
//  Created by Mark Suman on 4/18/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import "NSFileManager+CKAdditions.h"

@implementation NSFileManager (CKAdditions)

- (NSURL *)uniqueFileURLWithURL:(NSURL *)url
{    
    if (![self fileExistsAtPath:url.path]) {
        return url;
    }

    NSString *uniquePath = [NSString stringWithFormat:@"%@%@.%@", [url.path stringByDeletingPathExtension],
                                                                [[NSProcessInfo processInfo] globallyUniqueString],
                                                                url.pathExtension];
    return [NSURL fileURLWithPath:uniquePath];
}

@end
