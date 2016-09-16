//
//  MessageDetailViewController.m
//  iCanvas
//
//  Created by derrick on 11/27/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIMessageDetailViewController.h"
#import "CBIMessageComposeMessageViewModel.h"
#import "CBIMessageContentViewController.h"
#import "CBIMessageParticipantsViewModel.h"
#import "EXTScope.h"
#import <CanvasKit1/CanvasKit1.h>

#import "CBIMessageComposeMessageCell.h"
#import "CBIMessageParticipantsCell.h"

@interface CBIMessageDetailViewController ()
@property (weak, nonatomic) IBOutlet CBIMessageParticipantsCell *messageParticipantsCell;
@property (weak, nonatomic) IBOutlet CBIMessageComposeMessageCell *composeMessageCell;
@property (nonatomic, weak) CBIMessageContentViewController *contentViewController;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic) NSInteger composeMessageCellHeight;
@end

@implementation CBIMessageDetailViewController

- (id)init
{
    self = [[UIStoryboard storyboardWithName:@"CBIMessageDetail" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
    self.attachmentManager = [CKAttachmentManager new];
    self.attachmentManager.presentFromViewController = self;
    self.attachmentManager.viewAttachmentsOptionEnabled = YES;
    self.composeMessageCellHeight = 50.f;
    RAC(self, composeMessageCellHeight, @(50)) = [RACObserve(self, composeMessageCell.height) distinctUntilChanged];
    RAC(self, contentViewController.viewModel) = RACObserve(self, viewModel);

    @weakify(self);
    RACSignal *isUploadingSignal = RACObserve(self, viewModel.composeViewModel.isUploading);
    RACSignal *hasLoadedSignal = RACObserve(self, contentViewController.hasLoadedConversation);
    RACSignal *showLoadingSignal = [RACSignal combineLatest:@[isUploadingSignal, hasLoadedSignal] reduce:^id(NSNumber *isUploading, NSNumber *hasLoaded){
        @strongify(self);
        
        if ( ! self.viewModel.model) {
            return @(NO);
        }
        return @([isUploading boolValue] || ![hasLoaded boolValue]);
        
    }];
    
    [showLoadingSignal subscribeNext:^(id x) {
        @strongify(self);
        if ([x boolValue]){
            [self.activityIndicator startAnimating];
        } else {
            [self.activityIndicator stopAnimating];
        }
    }];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    @weakify(self);
    [[RACObserve(self, composeMessageCellHeight) distinctUntilChanged] subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CBIMessageContentSegue"]) {
        self.contentViewController = segue.destinationViewController;
        self.contentViewController.viewModel = self.viewModel;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    // DO NOT CALL SUPER.
    // THIS IS INTENTIONAL TO PREVENT KEYBOARD APPEARANCE OBSERVING.
    // The ConversationViewController observes the keyboard. Doesn't
    // need our help.
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 44.f;
    } else if (indexPath.row == 1) {
        return MAX(self.composeMessageCellHeight, 50);
    } else {
        UIEdgeInsets insets = self.tableView.contentInset;
        return self.tableView.frame.size.height - insets.bottom - insets.top - 44 - self.composeMessageCellHeight;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 2 && [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        [UIView performWithoutAnimation:^{
            [cell layoutIfNeeded];
        }];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == 0) {
        self.viewModel.participantsViewModel.viewControllerToPresentFrom = self;
        ((CBIMessageParticipantsCell *)cell).viewModel = self.viewModel.participantsViewModel;
    } else if (indexPath.row == 1) {
        CBIMessageComposeMessageCell *composeCell = (CBIMessageComposeMessageCell *)cell;
        self.viewModel.composeViewModel.attachmentManager = self.attachmentManager;
        self.attachmentManager.delegate = self.viewModel.composeViewModel;
        self.viewModel.composeViewModel.messageDetailTableViewController = self;
        composeCell.viewModel = self.viewModel.composeViewModel;
    }
    
    return cell;
}

@end
