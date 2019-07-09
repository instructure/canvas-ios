//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
