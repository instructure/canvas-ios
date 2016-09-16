//
//  CBIConversationStarter.h
//  iCanvas
//
//  Created by derrick on 2/26/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CBIConversationStarter <NSObject>
- (void)startAConversationWithRecipients:(NSArray *)conversationRecipients;
@end

@interface CBIConversationStarter : NSObject <CBIConversationStarter>
+ (instancetype)sharedConversationStarter;
@end
