//
//  CKIClient+CKIPollChoice.h
//  CanvasKit
//
//  Created by Rick Roberts on 5/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"
#import "CKIPoll.h"
#import "CKIPollChoice.h"

@interface CKIClient (CKIPollChoice)

- (RACSignal *)fetchPollChoicesForPoll:(CKIPoll *)poll;
- (RACSignal *)fetchPollChoiceWithId:(NSString *)pollChoiceId fromPoll:(CKIPoll *)poll;
- (RACSignal *)createPollChoice:(CKIPollChoice *)pollChoice forPoll:(CKIPoll *)poll;

@end
