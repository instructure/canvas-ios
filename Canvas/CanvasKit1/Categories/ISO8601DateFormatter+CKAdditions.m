//
//  ISO8601DateFormatter+CKAdditions.m
//  CanvasKit
//
//  Created by rroberts on 8/28/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "ISO8601DateFormatter+CKAdditions.h"

@implementation ISO8601DateFormatter (CKAdditions)

- (NSDate *)safeDateFromString:(NSString *)string {
    if (!string) {
        return nil;
    } else {
        return [self dateFromString:string timeZone:NULL];
    }
}

@end
