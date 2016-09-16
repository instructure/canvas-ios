//
//  CKFakeAttachment.h
//  CanvasKit
//
//  Created by BJ Homer on 9/28/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import "CKAttachment.h"

@interface CKFakeAttachment : CKAttachment

@property (nonatomic, weak) CKSubmissionAttempt *attempt;

- (id)initWithDisplayName:(NSString *)filename atIndex:(int)index andSubmissionAttempt:(CKSubmissionAttempt *)anAttempt;

@end
