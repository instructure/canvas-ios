//
//  CKIClient+CKIPollSession.h
//  CanvasKit
//
//  Created by Rick Roberts on 5/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"
@import ReactiveObjC;

#import "CKIPollSession.h"
#import "CKIPoll.h"

@interface CKIClient (CKIPollSession)

- (RACSignal *)createPollSession:(CKIPollSession *)session forPoll:(CKIPoll *)poll;
- (RACSignal *)closePollSession:(CKIPollSession *)session;
- (RACSignal *)publishPollSession:(CKIPollSession *)session;
- (RACSignal *)deletePollSession:(CKIPollSession *)session;
- (RACSignal *)fetchOpenPollSessionsForCurrentUser;
- (RACSignal *)fetchClosedPollSessionsForCurrentUser;
- (RACSignal *)fetchPollSessionsForPoll:(CKIPoll *)poll;
- (RACSignal *)fetchResultsForPollSession:(CKIPollSession *)pollSession;

@end
