//
//  CKAPICredentials.h
//  CanvasKit
//
//  Created by BJ Homer on 6/21/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CKCanvasAPI.h"

@interface CKAPICredentials : NSObject

@property (copy) NSString *userName;
@property (assign) uint64_t userIdent;
@property (copy) NSString *hostname;
@property (copy) NSString *apiProtocol;
@property (copy) NSString *accessToken;
@property (copy) NSString *actAsId;

+ (CKAPICredentials *)apiCredentialsFromKeychain;
+ (void)deleteCredentialsFromKeychain;
- (void)saveToKeychain;

// YES if all of the above properties are set (except actAsId), else NO;
- (BOOL)isValid;

- (BOOL)isEqual:(id)object;

@end
