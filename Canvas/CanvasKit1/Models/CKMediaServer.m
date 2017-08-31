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
    NSString *urlString = [NSString stringWithFormat:@"https://%@", apiAbsoluteString];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)apiURLUpload
{
    NSString *apiString = @"/api_v3/index.php?service=uploadtoken&action=upload";
    NSString *apiAbsoluteString = [[self.domain host] stringByAppendingPathComponent:apiString];
    NSString *urlString = [NSString stringWithFormat:@"https://%@", apiAbsoluteString];
    return [NSURL URLWithString:urlString];
}

- (NSURL *)apiURLAddFromUploadedFile
{
    NSString *apiString = @"/api_v3/index.php?service=media&action=addFromUploadedFile";
    NSString *apiAbsoluteString = [[self.domain host] stringByAppendingPathComponent:apiString];
    NSString *urlString = [NSString stringWithFormat:@"https://%@", apiAbsoluteString];
    return [NSURL URLWithString:urlString];
}

@end
