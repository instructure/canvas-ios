//
//  CBIMessageViewModel+CellViewModel.m
//  iCanvas
//
//  Created by derrick on 11/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIMessageViewModel+CellViewModel.h"
#import "CBIMessageCell.h"
#import "CBIMessageDetailViewController.h"
#import "UIViewController+Transitions.h"
#import "EXTScope.h"
@import CanvasKeymaster;
@import CocoaLumberjack;
#import "CBILog.h"

@implementation CBIMessageViewModel (CellViewModel)
- (UITableViewCell *)tableViewController:(MLVCTableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBIMessageCell *cell = [controller.tableView dequeueReusableCellWithIdentifier:@"CBIMessageCell"];
    cell.viewModel = self;
    return cell;
}

- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"didSelectMessage : %@ : %@", self.model.id, self.model.subject);
    if (controller.editing) {
        return;
    }
    
    CBIMessageDetailViewController *detail = [CBIMessageDetailViewController new];
    detail.viewModel = self;
    [controller cbi_transitionToViewController:detail animated:YES];
}

- (CGFloat)tableViewController:(MLVCTableViewController *)controller heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (BOOL)tableViewController:(MLVCTableViewController *)controller canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.model.workflowState != CKIConversationScopeArchived;
}

- (void)tableViewController:(MLVCTableViewController *)tableViewController commitEditingStyle:(UITableViewCellEditingStyle)style forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (style == UITableViewCellEditingStyleDelete) {
        MLVCCollectionController *collectionController = tableViewController.viewModel.collectionController;
        [[[CKIClient currentClient] markConversation:self.model asWorkflowState:CKIConversationWorkflowStateArchived] subscribeCompleted:^{
            [collectionController removeObjectAtIndexPath:indexPath];
        }];
    }
}

- (NSString *)tableViewController:(MLVCTableViewController *)tableViewController titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Archive", @"Archive selected messages button");
}

@end
