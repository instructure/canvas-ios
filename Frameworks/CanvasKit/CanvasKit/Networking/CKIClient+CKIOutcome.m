//
//  CKIClient+CKIOutcome.m
//  CanvasKit
//
//  Created by Brandon Pluim on 5/20/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient+CKIOutcome.h"
#import "CKIClient+CKIModel.h"

@import ReactiveObjC;
#import "CKIOutcome.h"

@implementation CKIClient (CKIOutcome)

- (RACSignal *)refreshOutcome:(CKIOutcome *)outcome courseID:(NSString *)courseID
{
    return [[self refreshModel:outcome parameters:nil] map:^id(CKIOutcome *outcome) {
        outcome.courseID = courseID;
        return outcome;
    }];
}

@end
