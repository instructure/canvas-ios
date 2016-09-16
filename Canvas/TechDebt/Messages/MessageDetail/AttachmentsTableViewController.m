//
//  AttachmentsTableViewController.m
//  iCanvas
//
//  Created by Stephen Lottermoser on 5/10/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
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
