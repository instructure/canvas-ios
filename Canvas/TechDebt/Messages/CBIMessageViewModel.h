//
//  CBIMessageViewModel.h
//  iCanvas
//
//  Created by derrick on 11/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MyLittleViewController;
#import "CBIViewModel.h"
#import "CBIMessageCell.h"

@class CKIConversation;
@class CBIMessageParticipantsViewModel;
@class CBIMessageComposeMessageViewModel;

@interface CBIMessageViewModel : CBIViewModel <MLVCViewModel>

@property (nonatomic) CKIConversation *model;

@property (nonatomic, copy) NSString *sender;
@property (nonatomic, copy) NSString *subject;
@property (nonatomic, copy) NSString *messagePreview;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) BOOL isUnread;
@property (nonatomic) BOOL hasAttachment;

@property (nonatomic, readonly) CBIMessageParticipantsViewModel *participantsViewModel;
@property (nonatomic, readonly) CBIMessageComposeMessageViewModel *composeViewModel;

@end
