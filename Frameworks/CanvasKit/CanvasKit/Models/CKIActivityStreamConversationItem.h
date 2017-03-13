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

#import "CKIActivityStreamItem.h"

@interface CKIActivityStreamConversationItem : CKIActivityStreamItem

/**
 This conversation item is private.
 */
@property (nonatomic) BOOL isPrivate;

/**
 The number of participants in the conversation.
 */
@property (nonatomic) NSUInteger participantCount;

/**
 The unique identifier for the conversation to which
 this stream item refers.
 */
@property (nonatomic, copy) NSString *conversationID;

@end
