//
//  CKIClient+CKIPollSubmission.h
//  CanvasKit
//
//  Created by Rick Roberts on 5/23/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"

#import "CKIPollSubmission.h"
#import "CKIPoll.h"
#import "CKIPollSession.h"

@interface CKIClient (CKIPollSubmission)

- (RACSignal *)createPollSubmission:(CKIPollSubmission *)submission forPoll:(CKIPoll *)poll pollSession:(CKIPollSession *)session;

@end
