//
//  NSString+CKAdditions.m
//  Speed Grader
//
//  Created by Zach Wily on 7/7/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import "NSString+CKAdditions.h"
#import <CommonCrypto/CommonDigest.h>


@implementation NSString (CKAdditions)

- (NSString *)md5Hash
{
    NSData *utfData = [self dataUsingEncoding:NSUTF8StringEncoding];
    const char *str = [utfData bytes];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, [utfData length], result);
    NSMutableString *hash = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; ++i) {
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
}

- (NSInteger)countOccurrencesOfString:(NSString *)aString
{
    NSInteger count = 0;
    
    NSRange r = [self rangeOfString:aString];
    while (r.location != NSNotFound) {
        count++;
        NSUInteger endOfMatch = r.location + r.length;
        r = [self rangeOfString:aString options:0 range:NSMakeRange(endOfMatch, [self length] - endOfMatch)];
    }
    
    return count;
}

- (NSString *)realURLEncodedString {
    NSString *str = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                        (__bridge CFStringRef)self,
                                                                        NULL,
                                                                        (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                        kCFStringEncodingUTF8);
    return str;
}

- (NSString *)ck_stringByMatching:(NSString *)regexStr capture:(NSUInteger)captureGroup {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexStr options:0 error:NULL];
    if (regex == nil) {
        return nil;
    }
    
    NSTextCheckingResult *result = [regex firstMatchInString:self options:0 range:NSMakeRange(0, [self length])];
    NSRange captureRange = [result rangeAtIndex:captureGroup];
    
    return [self substringWithRange:captureRange];
}

- (NSDictionary *)queryParameters {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSArray *pairs = [self componentsSeparatedByString:@"&"];
    for (NSString *pair in pairs) {
        if (pair.length == 0) {
            continue;
        }
        NSArray *things = [pair componentsSeparatedByString:@"="];
        NSString *key = things[0];
        id value = @"";
        if (things.count > 1) {
            value = things[1];   
        }
        dict[key] = value;
    }
    return dict;
}

- (NSString *)stringByRemovingNewlinesAndTrimmingWhitespace
{
    NSString *newString = [self stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return newString;
}

- (NSString *)stringByCollapsingWhitespace
{
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\s+" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *newString = [regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, self.length) withTemplate:@" "];
    return newString;
}

- (unsigned long long)unsignedLongLongValue {
    
    uint64_t value = 0;
    sscanf([self UTF8String], "%qu", &value);
    return value;
}

- (BOOL)equalIgnoringCase:(NSString *)string {
    // Initial check is in case of nil in which case YES would be sent back incorrectly
    if (string && [self caseInsensitiveCompare:string] == NSOrderedSame) {
        return YES;
    }
    return NO;
}

@end
