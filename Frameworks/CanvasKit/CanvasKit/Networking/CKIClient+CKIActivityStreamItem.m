//
//  CKIClient+CKIActivityStreamItem.m
//  CanvasKit
//
//  Created by Jason Larsen on 11/12/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

@import ReactiveObjC;

#import "CKIClient+CKIActivityStreamItem.h"
#import "CKIActivityStreamItem.h"
#import "CKICourse.h"

@implementation CKIClient (CKIActivityStreamItem)

- (RACSignal *)fetchActivityStreamForContext:(id<CKIContext>)context
{
    NSString *path = context.path;
    
    if ([path isEqualToString:@"/api/v1"] || path == (id)[NSNull null] || path.length == 0){
        path = @"/api/v1/users/self/activity_stream";
    }
    
    NSValueTransformer *transformer = [CKIActivityStreamItem activityStreamItemTransformer];
    return [self fetchResponseAtPath:path parameters:nil transformer:transformer context:nil];
}

- (RACSignal *)fetchActivityStream
{
    return [self fetchActivityStreamForContext:CKIRootContext];
}

@end
