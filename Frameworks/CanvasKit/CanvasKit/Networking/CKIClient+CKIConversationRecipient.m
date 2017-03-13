//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
