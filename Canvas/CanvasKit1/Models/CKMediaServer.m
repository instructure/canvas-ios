//
//  CKMediaServer.m
//  CanvasKit
//
//  Created by Mark Suman on 9/15/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKMediaServer.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKMediaServer

@synthesize enabled, domain, resourceDomain, partnerId;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        enabled = [info[@"enabled"] boolValue];
        NSString *domainString = [info objectForKeyCheckingNull:@"domain"];
        if (domainString) {
            if (![domainString hasPrefix:@"http"]) {
                domainString = [NSString stringWithFormat:@"http://%@",domainString];
            }
            domain = [[NSURL alloc] initWithString:domainString];
        }
        NSString *resourceDomainString = [info objectForKeyCheckingNull:@"resource_domain"];
        if (resourceDomainString) {
            if (![resourceDomainString hasPrefix:@"http"]) {
                resourceDomainString = [NSString stringWithFormat:@"http://%@",resourceDomainString];
            }
            resourceDomain = [[NSURL alloc] initWithString:resourceDomainString];
        }
        partnerId = [[info objectForKeyCheckingNull:@"partner_id"] unsignedLongLongValue];
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

@end
