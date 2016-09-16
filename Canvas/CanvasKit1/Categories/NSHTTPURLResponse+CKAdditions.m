//
//  NSHTTPURLResponse+CKAdditions.m
//  CanvasKit
//
//  Created by BJ Homer on 11/12/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import "NSHTTPURLResponse+CKAdditions.h"

@implementation NSHTTPURLResponse (CKAdditions)

- (NSDictionary *)ck_linkHeaderValues {
    
    NSString *linkValue = [self allHeaderFields][@"Link"];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSArray *splitValues = [linkValue componentsSeparatedByString:@","];
    for (NSString *pair in splitValues) {
        NSScanner *scanner = [[NSScanner alloc] initWithString:pair];
        [scanner scanString:@"<" intoString:NULL];
        
        NSString *value;
        [scanner scanUpToString:@">" intoString:&value];
        [scanner scanString:@">; rel=\"" intoString:NULL];
        
        NSString *valueName;
        [scanner scanUpToString:@"\"" intoString:&valueName];
        
        dict[valueName] = value;
    }
    return dict;
}

- (NSDate *)ck_date {
    static NSDateFormatter *rfc1123Formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // RFC 1123 date formatter pulled from http://blog.mro.name/2009/08/nsdateformatter-http-header/
        rfc1123Formatter = [[NSDateFormatter alloc] init];
        rfc1123Formatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
        rfc1123Formatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
        rfc1123Formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    });
    
    NSString *dateString = [self allHeaderFields][@"Date"];
    if (dateString) {
        return [rfc1123Formatter dateFromString:dateString];
    }
    else {
        return nil;
    }

}

@end
