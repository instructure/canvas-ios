//
//  CKCanvasAPIResponse.m
//  CanvasKit
//
//  Created by BJ Homer on 12/2/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPIResponse.h"
#import "TouchXML.h"
#import "NSString+INCal.h"

@interface CKCanvasAPIResponse ()
@property (readwrite, copy) NSData *data;
@end

@implementation CKCanvasAPIResponse
@synthesize data = _data;


- (id)initWithResponse:(NSHTTPURLResponse *)response data:(NSData *)data {
    self = [super initWithURL:response.URL
                   statusCode:response.statusCode
                  HTTPVersion:@"HTTP/1.1"
                 headerFields:response.allHeaderFields];
    if (self) {
        _data = [data copy];
    }
    return self;
}


#pragma mark - Read-only properties

- (id)JSONValue
{
    if (self.data) {
        NSError *error;
        id result = [NSJSONSerialization JSONObjectWithData:self.data options:0 error:&error];
        return result;
    }
    else {
        return nil;
    }
}

- (CXMLDocument *)XMLValue
{
    if (self.data) {
        return [[CXMLDocument alloc] initWithData:self.data options:0 error:nil];
    }
    else {
        return nil;
    }
}

- (NSDictionary *)ICSValue
{
    if (self.data) {
        NSString *responseString = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        return [responseString ICSValue];
    }
    else {
        return nil;
    }
}

@end
