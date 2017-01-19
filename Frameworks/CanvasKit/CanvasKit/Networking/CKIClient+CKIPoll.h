//
//  CKIClient+CKIPoll.h
//  CanvasKit
//
//  Created by Rick Roberts on 5/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"
#import "CKIPoll.h"

@interface CKIClient (CKIPoll)

- (RACSignal *)fetchPollsForCurrentUser;

- (RACSignal *)fetchPollWithID:(NSString *)pollID;

- (RACSignal *)createPoll:(CKIPoll *)poll;

- (RACSignal *)deletePoll:(CKIPoll *)poll;

@end
