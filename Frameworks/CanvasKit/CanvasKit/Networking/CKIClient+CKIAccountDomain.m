//
// Created by Brandon Pluim on 3/3/15.
// Copyright (c) 2015 Instructure. All rights reserved.
//

#import "CKIClient+CKIAccountDomain.h"
#import "CKIAccountDomain.h"

@implementation CKIClient (CKIAccountDomain)

+ (RACSignal *)fetchAccountDomains {
    CKIClient *tempClient = [[CKIClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://canvas.instructure.com"]];
    NSString *path = @"api/v1/accounts/search";
    return [tempClient fetchResponseAtPath:path parameters:nil modelClass:[CKIAccountDomain class] context:nil];
}

@end