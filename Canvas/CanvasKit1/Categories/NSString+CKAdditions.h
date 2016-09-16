//
//  NSString+CKAdditions.h
//  Speed Grader
//
//  Created by Zach Wily on 7/7/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (CKAdditions)

- (NSString *)md5Hash;

- (NSInteger)countOccurrencesOfString:(NSString *)aString;

- (NSString *)realURLEncodedString;

- (NSString *)ck_stringByMatching:(NSString *)regex capture:(NSUInteger)captureGroup;

- (NSDictionary *)queryParameters;

- (NSString *)stringByRemovingNewlinesAndTrimmingWhitespace;

- (NSString *)stringByCollapsingWhitespace;

- (unsigned long long)unsignedLongLongValue;

- (BOOL)equalIgnoringCase:(NSString *)string;

@end
