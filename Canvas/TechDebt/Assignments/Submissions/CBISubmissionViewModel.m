    //
//  CBISubmissionViewModel.m
//  iCanvas
//
//  Created by Derrick Hathaway on 9/15/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBISubmissionViewModel.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import "CBISubmissionCell.h"
#import "WebBrowserViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SubmissionAttachmentsController.h"
#import "Router+Routes.h"
#import "CBIExternalToolViewModel.h"
#import "CBILTIViewController.h"
#import "CBIQuizViewModel.h"
#import "CBISubmissionAnnotationPreviewHelper.h"
#import "UIImage+TechDebt.h"

@import PSPDFKit;
@import AnnotationKit;
@import CanvasKit;

static NSString *const CBISubmissionCellReuseIDAndNibName = @"CBISubmissionCell";
static UIImage *(^iconForSubmissionType)(NSString *) = ^(NSString *submissionType) {
    NSString *iconName = @"icon_document";
    if ([submissionType isEqualToString:CKISubmissionTypeOnlineTextEntry]) {
        iconName = @"icon_text";
    } else if ([submissionType isEqualToString:CKISubmissionTypeOnlineURL]) {
        iconName = @"icon_link";
    } else if ([submissionType isEqualToString:CKISubmissionTypeMediaRecording]) {
        iconName = @"icon_media";
    } else if ([submissionType isEqualToString:CKISubmissionTypeDiscussion]) {
        iconName = @"icon_discussions";
    } else if ([submissionType isEqualToString:CKISubmissionTypeQuiz]) {
        iconName = @"icon_quizzes";
    } else if ([submissionType isEqualToString:CKISubmissionTypeExternalTool]) {
        iconName = @"icon_tools";
    }
    
    return [[UIImage techDebtImageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
};

@implementation CBISubmissionViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        RAC(self, date) = RACObserve(self, model.submittedAt);
        RAC(self, name) = [RACObserve(self, model) map:^id(CKISubmission *submission) {
            
            NSDictionary *namesForTypes = @{
                CKISubmissionTypeOnlineTextEntry : NSLocalizedString(@"Text Submission", @"Title for a text submission cell"),
                CKISubmissionTypeQuiz: NSLocalizedString(@"Quiz", @"Title for a quiz submission cell"),
                CKISubmissionTypeExternalTool: NSLocalizedString(@"External Tool", @"Title for an external tool submission"),
                CKISubmissionTypeMediaRecording: NSLocalizedString(@"Media Submission", @"Title for a media submission"),
                CKISubmissionTypeDiscussion: NSLocalizedString(@"Discussion Entry", @"Title for discussion entry submission"),
            };
            
            if (namesForTypes[submission.submissionType]) {
                return namesForTypes[submission.submissionType];
            }
            
            if ([submission.submissionType isEqualToString:CKISubmissionTypeOnlineURL]) {
                return [submission.url host];
            }
            else if (submission.attachments.count == 1) {
                return [submission.attachments[0] name];
            }
            else if (submission.attachments.count > 1) {
                NSString *template = NSLocalizedString(@"%u files", @"Label indicating multiple files are attached to a single homework submission. %u will be a positive number, and will not be '1'");
                return [NSString stringWithFormat:template, submission.attachments.count];
            }
            return @"";
        }];
        RAC(self, subtitle) = [RACObserve(self, model.submittedAt) map:^id(NSDate *value) {
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            dateFormatter.timeStyle = NSDateFormatterMediumStyle;
            return [dateFormatter stringFromDate:value];
        }];
        
        RAC(self, icon) = [RACObserve(self, model.submissionType) map:iconForSubmissionType];
    }
    return self;
}


+ (void)registerCellsForTableView:(UITableView *)tableView {
    [tableView registerNib:[UINib nibWithNibName:CBISubmissionCellReuseIDAndNibName bundle:[NSBundle bundleForClass:self]] forCellReuseIdentifier:CBISubmissionCellReuseIDAndNibName];
}

- (CGFloat)tableViewController:(MLVCTableViewController *)controller heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static CBISubmissionCell *cell;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [controller.tableView dequeueReusableCellWithIdentifier:CBISubmissionCellReuseIDAndNibName];
    });
    
    cell.bounds = CGRectMake(0, 0, controller.tableView.bounds.size.width, 80.f);
    cell.viewModel = self;
    
    [cell setNeedsUpdateConstraints];
    [cell updateConstraintsIfNeeded];
    
    [cell setNeedsLayout];
    [cell layoutIfNeeded];
    
    CGFloat height = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    // make room for the separator.
    return height + 1;

}

- (UITableViewCell *)tableViewController:(MLVCTableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CBISubmissionCell *cell = [controller.tableView dequeueReusableCellWithIdentifier:CBISubmissionCellReuseIDAndNibName forIndexPath:indexPath];
    cell.viewModel = self;
    return cell;
}

- (void)presentSubmissionURL:(NSURL *)url fromViewController:(UIViewController *)submissionsViewController {
    UINavigationController *controller = (UINavigationController *)[[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
    WebBrowserViewController *browser = controller.viewControllers[0];
    [browser setUrl:url];
    [submissionsViewController presentViewController:controller animated:YES completion:nil];
}

- (void)playMediaAtURL:(NSURL *)url fromViewController:(UIViewController *)submissionViewController {
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [submissionViewController presentMoviePlayerViewControllerAnimated:player];
}

- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.model.submissionType isEqualToString:CKISubmissionTypeOnlineTextEntry]) {
        NSURL *url = self.model.urlForLocalTextEntryHTMLFile;
        [self presentSubmissionURL:url fromViewController:controller];
    } else if ([self.model.submissionType isEqualToString:CKISubmissionTypeDiscussion]) {
        NSURL *url = self.model.urlForLocalDiscussionEntriesHTMLFile;
        [self presentSubmissionURL:url fromViewController:controller];
    } else if ([self.model.submissionType isEqualToString:CKISubmissionTypeOnlineURL]) {
        NSURL *url = self.model.url;
        [self presentSubmissionURL:url fromViewController:controller];
    } else if (self.model.mediaComment) {
        [self playMediaAtURL:self.model.mediaComment.url fromViewController:controller];
    } else if (self.model.attachments.count == 1) {
        CKIFile *attachment = self.model.attachments[0];
        if (attachment.isMediaAttachment) {
            [self playMediaAtURL:attachment.url fromViewController:controller];
        } else if ([CBISubmissionAnnotationPreviewHelper filePreviewableWithAnnotations:attachment]) {
            [CBISubmissionAnnotationPreviewHelper loadAnnotationPreviewForFile:attachment fromViewController:controller];
        } else {
            [self presentSubmissionURL:attachment.url fromViewController:controller];
        }
    } else if ([self.assignment.submissionTypes containsObject:CKISubmissionTypeExternalTool]) {
        CKIExternalTool *tool = [CKIExternalTool new];
        tool.name = self.assignment.name;
        tool.url = self.assignment.url;
        CBIExternalToolViewModel *toolViewModel = [CBIExternalToolViewModel viewModelForModel:tool];
        toolViewModel.tintColor = self.tintColor;
        CBILTIViewController *lti = [CBILTIViewController new];
        lti.viewModel = toolViewModel;
        [controller.navigationController pushViewController:lti animated:YES];
    } else if ([self.model.submissionType isEqualToString:CKISubmissionTypeQuiz]) {
        CKIQuiz *quiz = [CKIQuiz modelWithID:self.assignment.quizID context:self.assignment.context];
        CBIQuizViewModel *quizVM = [CBIQuizViewModel viewModelForModel:quiz];
        [[Router sharedRouter] routeFromController:controller toViewModel:quizVM];
    } else {
        SubmissionAttachmentsController *attachmentsController = [SubmissionAttachmentsController new];
        attachmentsController.attachments = self.model.attachments;
        attachmentsController.liveURL = self.model.url;
        [controller.navigationController pushViewController:attachmentsController animated:YES];
    }
}


@end
