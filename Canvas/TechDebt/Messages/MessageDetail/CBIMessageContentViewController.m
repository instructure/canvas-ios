//
//  CBIMessageContentViewController.m
//  iCanvas
//
//  Created by derrick on 11/27/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIMessageContentViewController.h"
#import "CBIMessageViewModel.h"
#import <CanvasKit1/CanvasKit1.h>
#import "EXTScope.h"
#import "CBIMessageParticipantsViewModel.h"
#import "RatingsController.h"
@import CanvasKeymaster;

@interface CBIMessageContentViewController ()
@end

@implementation CBIMessageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.hasLoadedConversation) {
        return;
    }

    RACSignal *participantsAdded = self.viewModel.participantsViewModel.recipientsAddedSignal;
    RACSignal *messageCount = [RACObserve(self, viewModel.model.messageCount) distinctUntilChanged];
    [self rac_liftSelector:@selector(refreshConversationIgnoringValue:) withSignals:[RACSignal merge:@[messageCount, participantsAdded]], nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [RatingsController appLoadedOnViewController:self];
}

- (void)refreshConversationIgnoringValue:(id)ignored
{
    if (self.viewModel.model == nil) {
        return;
    }

    @weakify(self);
    [[[[CKIClient currentClient] refreshConversation:self.viewModel.model] map:^id(CKIConversation *updatedConversation) {
        NSDictionary *dict = [MTLJSONAdapter JSONDictionaryFromModel:updatedConversation];
        CKConversation *oldConversation = [[CKConversation alloc] initWithInfo:dict];
        return oldConversation;
    }] subscribeNext:^(CKConversation *legacyConversation) {
        @strongify(self);
        self.conversation = legacyConversation;
        self.hasLoadedConversation = YES;
    }];
}

@end
