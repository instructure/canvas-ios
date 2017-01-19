//
//  CKIClient+CKIService.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/11/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import ReactiveObjC;
#import "CKIClient+CKIService.h"
#include "CKIService.h"

@implementation CKIClient (CKIService)

- (RACSignal *)fetchService
{
    NSString *path = [CKIRootContext.path stringByAppendingPathComponent:@"services/kaltura"];
    return [self fetchResponseAtPath:path parameters:nil modelClass:[CKIService class] context:nil];
}

@end
