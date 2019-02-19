//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
