//
// Created by Brandon Pluim on 3/3/15.
// Copyright (c) 2015 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKIClient.h"

@interface CKIClient (CKIAccountDomain)

+ (RACSignal *)fetchAccountDomains;

@end