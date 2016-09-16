//
//  CKCanvasAPI+Conversations.h
//  CanvasKit
//
//  Created by nlambson on 6/12/13.
//  Copyright (c) 2013 Instructure, Inc. All rights reserved.
//

#import "CKCanvasAPI.h"

@interface CKCanvasAPI (Conversations)
- (void)fetchConversationsUnreadCountWithBlock:(CKObjectBlock)block;
@end
