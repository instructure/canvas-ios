//
//  NSString+IN_Additions.m
//  iCanvas
//
//  Created by BJ Homer on 11/11/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import "NSString+IN_Additions.h"

@implementation NSMutableString (IN_Additions)

- (void)in_replaceOccurrencesOfString:(NSString *)needle withString:(NSString *)replacement {
    if (replacement == nil) {
        replacement = @"";
    }
    
    [self replaceOccurrencesOfString:needle withString:replacement
                             options:0 range:NSMakeRange(0, self.length)];
}

@end
