//
//  NSURL+removeFragment.m
//  iCanvas
//
//  Created by Nathan Lambson on 4/22/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import "NSURL+RemoveFragment.h"

@implementation NSURL (RemoveFragment)

- (NSURL *)urlByRemovingFragment {
    NSString *urlString = [self absoluteString];
    // Find that last component in the string from the end to make sure to get the last one
    NSRange fragmentRange = [urlString rangeOfString:@"#" options:NSBackwardsSearch].location != NSNotFound ? [urlString rangeOfString:@"#" options:NSBackwardsSearch] : [urlString rangeOfString:@"%23" options:NSBackwardsSearch];
    if (fragmentRange.location != NSNotFound) {
        // Chop the fragment.
        NSString* newURLString = [urlString substringToIndex:fragmentRange.location];
        return [NSURL URLWithString:newURLString];
    } else {
        return self;
    }
}

@end
