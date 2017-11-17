//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
