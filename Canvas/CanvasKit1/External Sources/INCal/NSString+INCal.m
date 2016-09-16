//
//  NSString+INCal.m
//  CanvasKit
//
//  Created by Mark Suman on 10/12/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "NSString+INCal.h"
#import "INCalParser.h"

@implementation NSString (INCal)

- (id)ICSValue
{
    INCalParser *parser = [INCalParser new];
    return [parser objectWithString:self];
}

@end
