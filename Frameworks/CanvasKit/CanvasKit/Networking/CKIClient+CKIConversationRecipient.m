//
//  CKIClient+CKIConversationRecipient.m
//  CanvasKit
//
//  Created by Ben Kraus on 12/2/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKIClient+CKIConversationRecipient.h"
#import "CKIConversationRecipient.h"
#import "NSDictionary+DictionaryByAddingObjectsFromDictionary.h"

@implementation CKIClient (CKIConversationRecipient)

- (RACSignal *)fetchConversationRecipientsWithSearchString:(NSString *)search inContext:(NSString *)contextID
{
    NSString *path = [[CKIRootContext.path stringByAppendingPathComponent:@"search"] stringByAppendingPathComponent:@"recipients"];
    
    NSDictionary *params = @{@"search":[search stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
    if (contextID) {
        params = [params dictionaryByAddingObjectsFromDictionary:@{
                                                                   @"context": contextID,
                                                                   @"synthetic_contexts": @1
                                                                   }];
    }
    
    return [self fetchResponseAtPath:path parameters:params modelClass:[CKIConversationRecipient class] context:CKIRootContext];
}

@end
