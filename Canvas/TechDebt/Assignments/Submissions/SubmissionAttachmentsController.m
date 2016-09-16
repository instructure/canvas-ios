//
//  SubmissionAttachmentsController.m
//  iCanvas
//
//  Created by BJ Homer on 8/30/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "UIViewController+AnalyticsTracking.h"

#import "SubmissionAttachmentsController.h"
#import "WebBrowserViewController.h"
#import "CBISubmissionAnnotationPreviewHelper.h"
@import CanvasKit;

@implementation SubmissionAttachmentsController
@synthesize attachments;
@synthesize liveURL;
@synthesize popoverController;
@synthesize popoverPresenter;

- (id)init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
    }
    return self;
}

- (void)setAttachments:(NSArray *)someAttachments {
    attachments = someAttachments;
    
    [self calculateContentSizeForViewInPopover];
}

- (void)setLiveURL:(NSURL *)aLiveURL
{
    liveURL = aLiveURL;
    
    [self calculateContentSizeForViewInPopover];
}

- (void)calculateContentSizeForViewInPopover
{
    CGFloat contentHeight = 0;
    for (int i = 0; i < [self.tableView numberOfSections]; i++) 
    {
        CGRect sectionRect = [self.tableView rectForSection:i];
        contentHeight += sectionRect.size.height;
    }
    
    CGSize contentSize = CGSizeMake(320, contentHeight);
    self.preferredContentSize = contentSize;
}

#pragma mark - View lifecycle


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    return NSLocalizedString(@"Current Submission", @"Header for a section showing submitted filenames");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.onTappedResubmit ? 1 : 0;
    }
    else {
        if (attachments.count > 0) {
            return attachments.count;
        } else {
            return liveURL ? 1 : 0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.section == 0) {
        cell.textLabel.text = NSLocalizedString(@"Re-submit Assignment", @"Title for a button allowing user to re-submit files for an assignment");
    }
    else {   
        // Configure the cell...
        if (attachments.count > 0) {
            CKIFile *attachment = attachments[indexPath.row];
            cell.textLabel.text = attachment.name;
        } else if (liveURL) {
            cell.textLabel.text = [liveURL absoluteString];
        }
    }
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (self.onTappedResubmit) {
            self.onTappedResubmit();
        }
    }
    else {
        CKIFile *attachment = attachments[indexPath.row];
        
        UIViewController *presenter = popoverPresenter ?: self;
        
        if (popoverController) {
            [popoverController dismissPopoverAnimated:YES];
        }
        
        if (!attachment && liveURL) {
            UINavigationController *webNav = [[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
            [[webNav.viewControllers firstObject] setUrl:liveURL];
            self.modalPresentationStyle = UIModalPresentationFullScreen;
            [presenter presentViewController:webNav animated:YES completion:NULL];
        } else if ([attachment isMediaAttachment]) {
            MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:attachment.url];
            [presenter presentMoviePlayerViewControllerAnimated:player];
        } else {
            if ([CBISubmissionAnnotationPreviewHelper filePreviewableWithAnnotations:attachment]) {
                [CBISubmissionAnnotationPreviewHelper loadAnnotationPreviewForFile:attachment fromViewController:presenter];
            } else {
                UINavigationController *webNav = [[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
                [[webNav.viewControllers firstObject] setUrl:attachment.url];
                self.modalPresentationStyle = UIModalPresentationFullScreen;
                [presenter presentViewController:webNav animated:YES completion:NULL];
            }
        }
    }
}

@end
