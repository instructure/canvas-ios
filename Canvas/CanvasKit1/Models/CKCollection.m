//
//  CKCollection.m
//  CanvasKit
//
//  Created by Stephen Lottermoser on 5/31/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import "CKCollection.h"
#import "NSDictionary+CKAdditions.h"


@implementation CKCollection

@synthesize ident, name, visibility, isFollowedByUser, followersCount, itemsCount, collectionItems, rawInfo;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        ident = [info[@"id"] unsignedLongLongValue];
        name = [info objectForKeyCheckingNull:@"name"];
        isFollowedByUser = [[info objectForKeyCheckingNull:@"followed_by_user"] boolValue];
        followersCount = [[info objectForKeyCheckingNull:@"followers_count"] intValue];
        itemsCount = [[info objectForKeyCheckingNull:@"items_count"] intValue];
        [self setVisibilityWithString:[info objectForKeyCheckingNull:@"visibility"]];
        
        if (info.count > 6) {
            NSLog(@"The Collections API is returning new information! \n%@", info);
        }
    }
    return self;
}

- (void)setVisibilityWithString:(NSString *)aString
{
    if ([aString isEqualToString:@"public"]) {
        visibility = CKCollectionVisibilityPublic;
    } 
    else if ([aString isEqualToString:@"private"]) {
        visibility = CKCollectionVisibilityPrivate;
    } 
    else {
        NSAssert(NO, @"Unknown Collection visibility type: %@*visibility", aString);
    }
}

- (NSUInteger)hash {
    return ident;
}

@end
