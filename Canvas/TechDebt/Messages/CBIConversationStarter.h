//
//  CBIConversationStarter.h
//  TechDebt
//
//  Created by Derrick Hathaway on 10/6/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBIConversationRecipient : NSObject
@property (nonnull, nonatomic) NSString *name;
@property (nonnull, nonatomic) NSString *id;
@property (nullable, nonatomic) NSString *avatarURL;

- (instancetype _Nonnull)initWithName:(NSString * _Nonnull)name id:(NSString * _Nonnull)id avatarURL:(NSString * _Nullable)avatarURL;
@end

@interface CBIConversationStarter : NSObject
+ (void)setConversationStarter:(void (^ _Nonnull)(NSArray<CBIConversationRecipient *> * _Nonnull, NSString * _Nonnull context))starter;
+ (void)startAConversationWithRecipients:(NSArray<CBIConversationRecipient *> * _Nonnull)recipients inContext:(NSString * _Nonnull)context;
@end
