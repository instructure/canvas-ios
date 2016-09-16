//
//  ISO8601DateFormatter+CKAdditions.h
//  CanvasKit
//
//  Created by rroberts on 8/28/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "ISO8601DateFormatter.h"

@interface ISO8601DateFormatter (CKAdditions)

- (NSDate *)safeDateFromString:(NSString *)string;

@end
