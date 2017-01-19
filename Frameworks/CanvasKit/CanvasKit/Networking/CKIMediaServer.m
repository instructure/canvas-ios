//
//  CKIMediaServer.m
//  CanvasKit
//
//  Created by Rick Roberts on 11/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIMediaServer.h"

@implementation CKIMediaServer

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        self.enabled = [info[@"enabled"] boolValue];
        NSString *domainString = [self objectForKeyCheckingNull:@"domain" inDictionary:info];
        if (domainString) {
            if (![domainString hasPrefix:@"http"]) {
                domainString = [NSString stringWithFormat:@"http://%@",domainString];
            }
            self.domain = [[NSURL alloc] initWithString:domainString];
        }
        NSString *resourceDomainString = [self objectForKeyCheckingNull:@"resource_domain" inDictionary:info];
        if (resourceDomainString) {
            if (![resourceDomainString hasPrefix:@"http"]) {
                resourceDomainString = [NSString stringWithFormat:@"http://%@",resourceDomainString];
            }
            self.resourceDomain = [[NSURL alloc] initWithString:resourceDomainString];
        }
        self.partnerId = [self objectForKeyCheckingNull:@"partner_id" inDictionary:info];
    }
    
    return self;
}

- (NSURL *)apiURLAdd
{
    NSString *apiString = @"/api_v3/index.php?service=uploadtoken&action=add";
    NSString *apiAbsoluteString = [[self.domain host] stringByAppendingPathComponent:apiString];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@",[self.domain scheme], apiAbsoluteString];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)apiURLUpload
{
    NSString *apiString = @"/api_v3/index.php?service=uploadtoken&action=upload";
    NSString *apiAbsoluteString = [[self.domain host] stringByAppendingPathComponent:apiString];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@",[self.domain scheme], apiAbsoluteString];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)apiURLAddFromUploadedFile
{
    NSString *apiString = @"/api_v3/index.php?service=media&action=addFromUploadedFile";
    NSString *apiAbsoluteString = [[self.domain host] stringByAppendingPathComponent:apiString];
    NSString *urlString = [NSString stringWithFormat:@"%@://%@",[self.domain scheme], apiAbsoluteString];
    return [NSURL URLWithString:urlString];
}

- (id)objectForKeyCheckingNull:(id)aKey inDictionary:(NSDictionary *)dict
{
    id obj = dict[aKey];
    if (obj == [NSNull null]) {
        return nil;
    }
    return obj;
}

@end
