//
//  AFHTTPAvatarImageResponseSerializer.m
//  iCanvas
//
//  Created by rroberts on 12/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "AFHTTPAvatarImageResponseSerializer.h"

@implementation AFHTTPAvatarImageResponseSerializer

- (NSSet *)acceptableContentTypes
{
    return [NSSet setWithObjects:@"binary/octet-stream", @"image/jpeg", @"image/png", nil];
}

@end
