//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
            if (![domainString hasPrefix:@"https"]) {
                domainString = [NSString stringWithFormat:@"https://%@",domainString];
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
