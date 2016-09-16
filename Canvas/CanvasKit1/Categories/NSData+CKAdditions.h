//
//  NSData+CKAdditions.h
//  Speed Grader
//
//  Created by Mark Suman on 4/18/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (CKAdditions)

+ (id)dataWithBase64EncodedString:(NSString *)string;     //  Padding '=' characters are optional. Whitespace is ignored.
- (NSString *)base64Encoding;

@end
