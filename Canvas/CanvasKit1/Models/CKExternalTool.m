//
//  CKExternalTool.m
//  CanvasKit
//
//  Created by derrick on 6/24/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKExternalTool.h"

@implementation CKExternalTool

- (id)initWithName:(NSString *)name createSessionURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        _name = name;
        _createSessionURL = url;
    }
    return self;
}

- (NSUInteger)hash
{
    static const NSUInteger prime = 37;
    NSUInteger result = 1;
    
    result = prime * result + [self.name hash];
    result = prime * result + [self.createSessionURL hash];
    
    return result;
}

@end
