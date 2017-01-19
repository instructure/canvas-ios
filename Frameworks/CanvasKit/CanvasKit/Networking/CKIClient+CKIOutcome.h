//
//  CKIClient+CKIOutcome.h
//  CanvasKit
//
//  Created by Brandon Pluim on 5/20/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"

@class CKIOutcome;

@interface CKIClient (CKIOutcome)

- (RACSignal *)refreshOutcome:(CKIOutcome *)outcome courseID:(NSString *)courseID;

@end
