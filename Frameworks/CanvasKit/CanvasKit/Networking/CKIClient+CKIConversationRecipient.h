//
//  CKIClient+CKIConversationRecipient.h
//  CanvasKit
//
//  Created by Ben Kraus on 12/2/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient.h"

@interface CKIClient (CKIConversationRecipient)

- (RACSignal *)fetchConversationRecipientsWithSearchString:(NSString *)search inContext:(NSString *)contextID;

@end
