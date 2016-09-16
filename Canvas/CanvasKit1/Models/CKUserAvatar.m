//
//  CKUserAvatar.m
//  CanvasKit
//
//  Created by Joshua Dutton on 6/18/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import "CKUserAvatar.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKUserAvatar

@synthesize type, URL, token, displayName;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        [self setTypeFromString:[info objectForKeyCheckingNull:@"type"]];
        token = [info objectForKeyCheckingNull:@"token"];
        displayName = [info objectForKeyCheckingNull:@"display_name"];
        NSString *urlString = [info objectForKeyCheckingNull:@"url"];
        if (urlString) {
            URL = [NSURL URLWithString:urlString];
        }
    }
    return self;
}

- (void)setTypeFromString:(NSString *)aString
{
    if ([aString isEqualToString:@"gravatar"]) {
        type = CKUserAvatarTypeGravatar;
    }
    else if ([aString isEqualToString:@"twitter"]) {
        type = CKUserAvatarTypeTwitter;
    }
    else if ([aString isEqualToString:@"linked_in"]) {
        type = CKUserAvatarTypeLinkedIn;
    }
    else if ([aString isEqualToString:@"attachment"]) {
        type = CKUserAvatarTypeAttachement;
    }
    else if ([aString isEqualToString:@"no_pic"]) {
        type = CKUserAvatarTypeNoPic;
    }
}

- (NSUInteger)hash {
    return self.URL.hash;
}

@end
