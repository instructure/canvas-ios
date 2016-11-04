
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
    
    

#import "CBIMessageComposeMessageViewModel.h"
#import "CBIMessageComposeMessageCell.h"
#import "EXTScope.h"
#import "AttachmentsTableViewController.h"

#import "CBIMessageParticipantsViewModel.h"
#import "RatingsController.h"
@import CanvasKeymaster;
#import "CKCanvasAPI+CurrentAPI.h"

@import MyLittleViewController;

@import SoPretty;

@interface CBIMessageComposeMessageViewModel ()
@property (nonatomic) UIPopoverController *popover;
@property (nonatomic, weak) UITableViewController *tableViewController;
@property (nonatomic, weak) UIButton *attachmentsButton;
@end

@implementation CBIMessageComposeMessageViewModel

+ (void)initialize
{
    UINavigationBar *appearanceProxy = [UINavigationBar appearanceWhenContainedIn:[UIPopoverController class], nil];
    [appearanceProxy setTintColor:Brand.current.tintColor];
    [appearanceProxy setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor prettyBlack]}];
}

- (void)sendMessageFromTextView:(UITextView *)textView
{
    NSString *message = textView.text;
    textView.text = @"";
    [textView resignFirstResponder];
    
    @weakify(self)

    CKObjectBlock completionBlock = ^(NSError *error, BOOL isFinal, id object) {
        @strongify(self);
        self.isUploading = NO;
        if (error) {
            NSLog(@"there was an error sending a message");
            NSString *title = NSLocalizedString(@"Upload Error", @"title for upload error alert");
            NSString *errorMessage = error.localizedDescription;
            NSString *dismissButton = NSLocalizedString(@"Dismiss", @"Dismiss button title");

            NSData *data = [error.localizedDescription dataUsingEncoding:NSUTF8StringEncoding];
            id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if (json) {
                errorMessage = json[0][@"message"];
            }

            NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Upload failed. Reason: (%@)", @"explanation of upload failure"), errorMessage];
            
            [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:dismissButton otherButtonTitles:nil] show];
            return ;
        } else if(isFinal) {
            @strongify(self);
            [self.attachmentManager clearAttachments];
            [self.model mergeNewMessageFromConversation:self.model];
            self.participantsViewModel.pendingRecipients = @[];
            if (self.model) {
                [[[CKIClient currentClient] refreshConversation:self.model] subscribeError:^(NSError *error) {
                    NSLog(@"error updating the conversation");
                } completed:^{
                    NSLog(@"Completed updating the conversation");
                }];
            }

            ToastManager *toastManager = [ToastManager new];
            [toastManager statusBarToastSuccess:NSLocalizedString(@"Message Sent.", @"notification that a message has been sent succesfully")];

            [self.attachmentManager clearAttachments];
            [RatingsController appLoadedOnViewController:self.tableViewController];
        }
    };
    
    CKCanvasAPI *api = [CKCanvasAPI currentAPI];
    self.isUploading = YES;
    
    if (self.model) {
       CKConversation *conversation = [[CKConversation alloc] initWithInfo:[self.model JSONDictionary]];
        [api postMessage:message withAttachments:self.attachmentManager.attachments toConversation:conversation withBlock:completionBlock];
    } else {
        NSMutableArray *recipientIDs = [NSMutableArray new];
        [self.participantsViewModel.pendingRecipients enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([obj isKindOfClass:[CKIConversationRecipient class]]) {
                [recipientIDs addObject:[obj id]];
            } else if ([obj isKindOfClass:[CKConversationRecipient class]]) {
                [recipientIDs addObject:[obj identString]];
            }
            
        }];
        
        [api startNewConversationWithRecipients:recipientIDs message:message attachments:self.attachmentManager.attachments groupConversation:NO block:completionBlock];
    }
}

- (void)addAttachmentsFromButton:(UIButton *)button
{
    self.attachmentsButton = button;
    
    // Attempt to fix crash caused when controller.view has not been added to the window
    // This should never happen as this is tied to a rac_command (view should be on window when pressed)
    // Crashlytics: 3299, 2978, 3188, 2871, 2907
    if (self.messageDetailTableViewController.view.window) {
        UIView *view = self.messageDetailTableViewController.view;
        self.attachmentManager.presentFromViewController = self.messageDetailTableViewController;
        [self.attachmentManager showAttachmentPickerFromRect:[button convertRect:button.bounds toView:view] inView:view permittedArrowDirections:UIPopoverArrowDirectionAny withSheetTitle:NSLocalizedString(@"Add Attachment", @"title for Messages attachment action sheet")];
    }
}

- (UITableViewCell *)tableViewController:(MLVCTableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableViewController = controller;
    
    CBIMessageComposeMessageCell *cell = [controller.tableView dequeueReusableCellWithIdentifier:@"CBIMessageNewMessageCell"];
    cell.separatorInset = UIEdgeInsetsZero;
    
    return cell;
}

#pragma mark - CKAttachmentManagerDelegate

- (void)attachmentManager:(CKAttachmentManager *)manager didAddAttachmentAtIndex:(NSUInteger)index
{
    self.attachmentCount = [manager.attachments count];
}

- (void)attachmentManager:(CKAttachmentManager *)manager didRemoveAttachmentAtIndex:(NSUInteger)index
{
    self.attachmentCount = [manager.attachments count];
}

- (void)attachmentManagerDidRemoveAllAttachments:(CKAttachmentManager *)manager
{
    self.attachmentCount = 0;
    self.currentTextEntry = @"";
}

- (void)showAttachmentsForAttachmentManager:(CKAttachmentManager *)manager
{
    AttachmentsTableViewController *attachments = [AttachmentsTableViewController new];
    attachments.attachmentManager = self.attachmentManager;
    UINavigationController *attachmentsNav = [[UINavigationController alloc] initWithRootViewController:attachments];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        if (self.popover) {
            [self.popover dismissPopoverAnimated:NO];
        }
        self.popover = [[UIPopoverController alloc] initWithContentViewController:attachmentsNav];
        
        UIView *presentationView = self.messageDetailTableViewController.view;
        [self.popover presentPopoverFromRect:[self.attachmentsButton convertRect:self.attachmentsButton.bounds toView:presentationView] inView:presentationView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self.messageDetailTableViewController presentViewController:attachmentsNav animated:YES completion:nil];
    }
}
@end
