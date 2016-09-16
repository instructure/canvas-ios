//
//  CKByteCountFormatter.m
//  CanvasKit
//
//  Created by BJ Homer on 7/18/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import "CKByteCountFormatter.h"

@implementation CKByteCountFormatter

- (NSString *)stringFromByteCount:(long long)byteCount {
    
    if (byteCount >= 1 * 1000 * 1000 * 1000) {
        NSString *template = NSLocalizedString(@"%0.2f GB", @"Gigabytes");
        return [NSString stringWithFormat:template, (double)byteCount / (1 * 1000 * 1000 * 1000)];
    }
    else if (byteCount >= 1 * 1000 * 1000) {
        NSString *template = NSLocalizedString(@"%0.2f MB", @"Megabytes");
        return [NSString stringWithFormat:template, (double)byteCount / (1 * 1000 * 1000)];
    }
    else if (byteCount >= 1 * 1000) {
        NSString *template = NSLocalizedString(@"%0.2f KB", @"Kilobytes");
        return [NSString stringWithFormat:template, (double)byteCount / (1 * 1000)];
    }
    else {
        NSString *template = NSLocalizedString(@"%qu bytes", @"As in, '15 bytes'");
        return [NSString stringWithFormat:template, byteCount];
    }
    
}


@end
