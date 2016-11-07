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
    
    

#import <CanvasKit1/CanvasKit1.h>
#import "UIViewController+AnalyticsTracking.h"
#import "Analytics.h"
#import "AttachmentsTableViewController.h"
#import "CKAttachmentManager.h"


@interface AttachmentsTableViewController () <UITableViewDelegate>

@end

@implementation AttachmentsTableViewController
@synthesize attachmentManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Attachments", @"Table View Controller for Attachments") ;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self.attachmentManager;
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                      target:self
                                                                                      action:@selector(dismissSelf)];
        self.navigationItem.leftBarButtonItem = cancelButton;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    NSLog(@"Tracking: %@", kGAIScreenAttachmentsList);
    
    [Analytics logScreenView:kGAIScreenAttachmentsList];
}

- (void)dismissSelf
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UITableViewDelegate methods

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CKURLPreviewViewController *previewController = [[CKURLPreviewViewController alloc] init];
    previewController.title = [NSString stringWithFormat:NSLocalizedString(@"Attachment %i", @"An item for attaching to a conversation"), indexPath.row + 1];
    CKEmbeddedMediaAttachment *attachment = (self.attachmentManager.attachments)[indexPath.row];
    previewController.url = attachment.url;
    previewController.modalBarStyle = UIBarStyleBlack;
    previewController.preferredContentSize = self.view.bounds.size;
    
    [self.navigationController pushViewController:previewController animated:YES];
}

@end
