//
//  NSHTTPURLResponse+Pagination.m
//  CanvasKit
//
//  Created by Jason Larsen on 9/19/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <objc/runtime.h>

#import "NSHTTPURLResponse+Pagination.h"

@interface NSString (QueryParsing)
- (NSDictionary *)ck_queryParameters;
@end

@implementation NSString (QueryParsing)

- (NSDictionary *)ck_queryParameters {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSURL *url = [NSURL URLWithString:self];
    
    NSArray *pairs = [url.query componentsSeparatedByString:@"&"];
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

@end


@interface NSHTTPURLResponse (LinkHeaderParsing)
@property (nonatomic, copy) NSDictionary *ck_linkHeader;
@end

@implementation NSHTTPURLResponse (LinkHeaderParsing)


- (NSDictionary *)ck_linkHeader
{
    NSDictionary *linkHeader = objc_getAssociatedObject(self, @selector(ck_linkHeader));
    if (!linkHeader) {
        linkHeader = [self ck_parseHeaderPaginationData];
        [self setCk_linkHeader:linkHeader];
    }
    return linkHeader;
}

- (void)setCk_linkHeader:(NSDictionary *)ck_linkHeader
{
    objc_setAssociatedObject(self, @selector(ck_linkHeader), ck_linkHeader, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)ck_parseHeaderPaginationData {
    
    NSString *linkValue = [self allHeaderFields][@"Link"];
    
    NSMutableDictionary *values = [NSMutableDictionary dictionary];
    
    NSArray *splitValues = [linkValue componentsSeparatedByString:@","];
    for (NSString *pair in splitValues) {
        NSScanner *scanner = [[NSScanner alloc] initWithString:pair];
        [scanner scanString:@"<" intoString:NULL];
        
        NSString *value;
        [scanner scanUpToString:@">" intoString:&value];
        [scanner scanString:@">; rel=\"" intoString:NULL];
        
        NSString *valueName;
        [scanner scanUpToString:@"\"" intoString:&valueName];
        
        values[valueName] = [NSURL URLWithString:value];
    }
    
    return values;
}

@end

@implementation NSHTTPURLResponse (Pagination)


- (NSURL *)currentPage
{
    return self.ck_linkHeader[@"current"];
}

- (NSURL *)nextPage
{
    return self.ck_linkHeader[@"next"];
}

- (NSURL *)previousPage
{
    return self.ck_linkHeader[@"prev"];
}

- (NSURL *)firstPage
{
    return self.ck_linkHeader[@"first"];
}

- (NSURL *)lastPage
{
    return self.ck_linkHeader[@"last"];
}

@end
