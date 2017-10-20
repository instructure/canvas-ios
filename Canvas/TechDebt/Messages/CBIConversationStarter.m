//
//  CBIConversationStarter.m
//  TechDebt
//
//  Created by Derrick Hathaway on 10/6/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

#import "CBIConversationStarter.h"

@implementation CBIConversationRecipient

- (instancetype _Nonnull)initWithName:(NSString * _Nonnull)name id:(NSString * _Nonnull)id avatarURL:(NSString * _Nullable)avatarURL {
    if (self = [super init]) {
        self.name = name;
        self.id = id;
        self.avatarURL = avatarURL;
        return self;
    }
    return nil;
}

@end

@interface CBIConversationStarter ()
@property (nonatomic) void (^ _Nonnull starterBlock)(NSArray<CBIConversationRecipient *> * _Nonnull recipients, NSString * _Nonnull context);
@end

static void (^_starter)(NSArray<CBIConversationRecipient *> * _Nonnull, NSString * _Nonnull context);

@implementation CBIConversationStarter

+ (void)setConversationStarter:(void (^ _Nonnull)(NSArray<CBIConversationRecipient *> * _Nonnull, NSString * _Nonnull context))starter {
    _starter = starter;
}

+ (void)startAConversationWithRecipients:(NSArray<CBIConversationRecipient *> * _Nonnull)recipients inContext:(NSString * _Nonnull)context {
    if (_starter) {
        _starter(recipients, context);
    }
}

@end
