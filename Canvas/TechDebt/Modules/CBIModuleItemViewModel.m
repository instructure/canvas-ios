//
//  CBIModuleItemViewModel.m
//  iCanvas
//
//  Created by derrick on 11/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIModuleItemViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "EXTScope.h"
#import "CBIColorfulViewModel+CellViewModel.h"
#import "CBIModuleItemSubheaderCell.h"
#import "CBIPageViewModel.h"
#import "CBIFileViewModel.h"
#import "CBIDiscussionTopicViewModel.h"
#import "CBIAssignmentViewModel.h"
#import "CBIDiscussionTopicViewModel.h"
#import "CBIQuizViewModel.h"
#import "Router.h"
#import "CBIExternalToolViewModel.h"
#import "CBISplitViewController.h"
#import "CBIModuleProgressNotifications.h"
@import CanvasKeymaster;
#import "CBILog.h"
#import "UIImage+TechDebt.h"

@interface CBIModuleItemViewModel ()
@property (nonatomic) RACDisposable *observeSubmissions;
@end

@implementation CBIModuleItemViewModel
@synthesize lockedOut;
@synthesize state;
@synthesize selected;

static UIImage *(^imageForType)(NSString *) = ^UIImage *(NSString *typeString) {
    NSString *imageName = @"assignments";
    if ([typeString isEqualToString:CKIModuleItemTypeQuiz]) {
        imageName = @"quizzes";
    } else if ([typeString isEqualToString:CKIModuleItemTypePage]) {
        imageName = @"pages";
    } else if ([typeString isEqualToString:CKIModuleItemTypeFile]) {
        imageName = @"folder";
    } else if ([typeString isEqualToString:CKIModuleItemTypeDiscussion]) {
        imageName = @"discussions";
    } else if ([typeString isEqualToString:CKIModuleItemTypeExternalURL]) {
        imageName = @"link";
    } else if ([typeString isEqualToString:CKIModuleItemTypeExternalTool]) {
        imageName = @"application";
    } else if ([typeString isEqualToString:CKIModuleItemTypeSubHeader]) {
        return nil;
    }
    return [[UIImage techDebtImageNamed:[NSString stringWithFormat:@"icon_%@", imageName]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
};

- (CBIViewModel *)viewModelForModuleItem
{
    CKIModuleItem *item = self.model;
    if (item == nil) {
        return nil;
    }
    
    CBIViewModel *viewModel;
    if ([item.type isEqualToString:CKIModuleItemTypePage]) {
        viewModel = [CBIPageViewModel viewModelForModel:[CKIPage modelWithID:item.itemID context:item.context.context]];
    } else if ([item.type isEqualToString:CKIModuleItemTypeFile]) {
        viewModel = [CBIFileViewModel viewModelForModel:[CKIFile modelWithID:item.itemID context:item.context.context]];
    } else if ([item.type isEqualToString:CKIModuleItemTypeDiscussion]) {
        viewModel = [CBIDiscussionTopicViewModel viewModelForModel:[CKIDiscussionTopic modelWithID:item.itemID context:item.context.context]];
    } else if ([item.type isEqualToString:CKIModuleItemTypeAssignment]) {
        viewModel = [CBIAssignmentViewModel viewModelForModel:[CKIAssignment modelWithID:item.itemID context:item.context.context]];
    } else if ([item.type isEqualToString:CKIModuleItemTypeExternalTool]) {
        CKIExternalTool *tool = [CKIExternalTool modelWithID:item.itemID context:item.context.context];
        tool.url = item.apiURL;
        viewModel = [CBIExternalToolViewModel viewModelForModel:tool];
    } else if ([item.type isEqualToString:CKIModuleItemTypeQuiz]) {
        viewModel = [CBIQuizViewModel viewModelForModel:[CKIQuiz modelWithID:item.itemID context:item.context.context]];
    }
    
    return viewModel;
};

static NSString *(^subtitleForRequirementAndMinScoreBlock)(NSString *, NSNumber *) = ^id(NSString *requirement, NSNumber *minScore) {
    if (!requirement) {
        return nil;
    }
    
    if ([requirement isEqualToString:CKIModuleItemCompletionRequirementMustView]) {
        return [NSString stringWithFormat:NSLocalizedString(@"Must view", @"user must view item to complete requirement")];;
    } else if ([requirement isEqualToString:CKIModuleItemCompletionRequirementMustContribute]) {
        return [NSString stringWithFormat:NSLocalizedString(@"Must contribute", @"user must contribute to complete requirement")];
    } else if ([requirement isEqualToString:CKIModuleItemCompletionRequirementMustSubmit]) {
        return [NSString stringWithFormat:NSLocalizedString(@"Must submit", @"user must submit something to complete requirement")];
    } else if ([requirement isEqualToString:CKIModuleItemCompletionRequirementMinimumScore]) {
        return [NSString stringWithFormat:NSLocalizedString(@"Must score %@ or higher", @"format string saying what the minimum score must be"), minScore];
    } else if ([requirement isEqualToString:CKIModuleItemCompletionRequirementMustMarkDone]) {
        return [NSString stringWithFormat:NSLocalizedString(@"Must mark as done", @"user must mark item as done to complete requirement")];
    }
    return nil;
};

static NSNumber *(^stateForRequirementCompletedBlock)(NSString *, NSNumber *, NSNumber *) = ^NSNumber *(NSString *requirement, NSNumber *completed, NSNumber *lockedOut) {
    if ([lockedOut boolValue]) {
        return @(CBIColorfulModuleViewModelStateLocked);
    } else if (requirement == nil) {
        return @(CBIColorfulModuleViewModelStateNone);
    } else if ([completed boolValue]) {
        return @(CBIColorfulModuleViewModelStateCompleted);
    } else {
        return @(CBIColorfulModuleViewModelStateIncomplete);
    }
};

static NSString *(^accessibilityLabelBlock)(NSString *, NSString *, NSString *, NSString *, NSNumber *, NSNumber *) = ^NSString *(NSString *name, NSString *subtitle, NSString *type, NSString *requirement, NSNumber *completed, NSNumber *lockedOut) {

    NSString *typeStringToRead = nil;
    if ([type isEqualToString:CKIModuleItemTypeFile]) {
        typeStringToRead = NSLocalizedString(@"File", @"");
    } else if ([type isEqualToString:CKIModuleItemTypePage]) {
        typeStringToRead = NSLocalizedString(@"Page", @"");
    } else if ([type isEqualToString:CKIModuleItemTypeDiscussion]) {
        typeStringToRead = NSLocalizedString(@"Discussion", @"");
    } else if ([type isEqualToString:CKIModuleItemTypeAssignment]) {
        typeStringToRead = NSLocalizedString(@"Assignment", @"");
    } else if ([type isEqualToString:CKIModuleItemTypeQuiz]) {
        typeStringToRead = NSLocalizedString(@"Quiz", @"");
    } else if ([type isEqualToString:CKIModuleItemTypeSubHeader]) {
        typeStringToRead = NSLocalizedString(@"Sub Header", @"");
    } else if ([type isEqualToString:CKIModuleItemTypeExternalURL]) {
        typeStringToRead = NSLocalizedString(@"External URL", @"");
    } else if ([type isEqualToString:CKIModuleItemTypeExternalTool]) {
        typeStringToRead = NSLocalizedString(@"External Tool", @"");
    }

    // For some reason it wasn't working when I observed the status on self, and just mapped that to a string /shrug
    // So I did the same as above
    NSString *statusStringToRead = nil;
    if ([lockedOut boolValue]) {
        statusStringToRead = NSLocalizedString(@"Locked", @"");
    } else if (requirement == nil) {
        statusStringToRead = nil;
    } else if ([completed boolValue]) {
        statusStringToRead = NSLocalizedString(@"Completed", @"");
    } else {
        statusStringToRead = NSLocalizedString(@"Incomplete", @"");
    }

    if (subtitle == nil) { subtitle = @""; }

    if (statusStringToRead != nil) {
        return [NSString stringWithFormat:NSLocalizedString(@"%@. %@. Type: %@. Status: %@", @"String to be read for the blind users. Name of item in module, then type of thing, then status."), name, subtitle, typeStringToRead, statusStringToRead];
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"%@. %@. Type: %@.", @"String to be read for the blind users. Name of item in module, then type of thing."), name, subtitle, typeStringToRead];
    }
};

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.title);
        RAC(self, viewControllerTitle) = RACObserve(self, model.title);
        RAC(self, icon) = [RACObserve(self, model.type) map:imageForType];
        RAC(self, subtitle) = [RACSignal combineLatest:@[RACObserve(self, model.completionRequirement), RACObserve(self, model.minimumScore)] reduce:subtitleForRequirementAndMinScoreBlock];
        RAC(self, state) = [RACSignal combineLatest:@[RACObserve(self, model.completionRequirement), RACObserve(self, model.completed), RACObserve(self, lockedOut)] reduce:stateForRequirementCompletedBlock];
        RAC(self, accessibilityLabel) = [RACSignal combineLatest:@[RACObserve(self, name), RACObserve(self, subtitle), RACObserve(self, model.type), RACObserve(self, model.completionRequirement), RACObserve(self, model.completed), RACObserve(self, lockedOut)] reduce:accessibilityLabelBlock];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshItemProgress:) name:CBIModuleItemProgressUpdatedNotification object:nil];
    }
    return self;
}

- (void)refreshItemProgress:(NSNotification *)note
{
    NSString *itemID;
    if ([self.model.type isEqualToString:CKIModuleItemTypeExternalTool]) {
        itemID = [self.model.htmlURL absoluteString];
    } else {
        itemID = self.model.itemID ?: self.model.id;
    }
    
    NSString *noteItemID = note.userInfo[CBIUpdatedModuleItemIDStringKey];
    NSString *noteRequirementType = note.userInfo[CBIUpdatedModuleItemTypeKey];

    if (!self.model.completed && [noteItemID isEqualToString:itemID] && [noteRequirementType isEqualToString:self.model.completionRequirement]) {
        @weakify(self);
        [[[CKIClient currentClient] refreshModel:self.model parameters:nil] subscribeCompleted:^{
            @strongify(self);
            if (self.model.completed) {
                CBIPostModuleProgressUpdate(self.model.context.id);
            }
        }];
    }

    NSString *noteSelectedItemID = note.userInfo[CBISelectedModuleItemIDStringKey];
    if (noteSelectedItemID) {
        self.selected = [itemID isEqualToString:noteSelectedItemID];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UITableViewCell *)tableViewController:(MLVCTableViewController *)controller cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.model.type isEqualToString:CKIModuleItemTypeSubHeader]) {
        CBIModuleItemSubheaderCell *cell = [controller.tableView dequeueReusableCellWithIdentifier:@"CBIModuleItemSubheaderCell"];
        cell.viewModel = self;
        return cell;
    }

    return [super tableViewController:controller cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableViewController:(MLVCTableViewController *)controller heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.model.type isEqualToString:CKIModuleItemTypeSubHeader]) {
        CGRect bounds = [self.model.title boundingRectWithSize:CGSizeMake(controller.view.bounds.size.width - 30.f, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:14]} context:nil];
        return bounds.size.height + 14.f + 1.0f; // 1 is to possibly account for the cell separator... the last  word possibly gets truncated without it
    }
    return 52.f;
}

- (void)tableViewController:(MLVCTableViewController *)controller didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogVerbose(@"didSelectModule : %@ : %@", self.model.id, self.model.title);


    if ([self.model.type isEqualToString:CKIModuleItemTypeSubHeader]) {
        return;
    }
    
    // Module progression tom-foolery since we select the cell as they progress through the module on iPad.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [controller.tableView deselectRowAtIndexPath:indexPath animated:NO];
        [[controller.tableView cellForRowAtIndexPath:indexPath] setSelected:YES animated:NO];
    }

    [[Router sharedRouter] routeFromController:controller toViewModel:self];
}

- (WebBrowserViewController *)browserViewControllerForModuleItem
{
    WebBrowserViewController *browser = nil;

    if (self.model.externalURL) {
        UINavigationController *nav = (UINavigationController *)[[UIStoryboard storyboardWithName:@"Storyboard-WebBrowser" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
        browser = nav.viewControllers[0];
        [browser setUrl:self.model.externalURL];
        [nav setModalPresentationStyle:UIModalPresentationFullScreen];

        if (self.model.htmlURL) {
            // We need to mark the item as viewed. We don't care if this request fails (it will likely fail
            // due to parsing issues), but the failure will happen after the redirect, and at that point
            // we don't really care what happens because canvas has been notified that the item has been
            // viewed. I'm happy if you're happy, canvas.
            [[CKIClient currentClient] GET:[self.model.htmlURL path] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                DDLogVerbose(@"CBImoduleItemViewModel posting module item progress update after succesfully marking External URL Module Item as viewed");
                CBIPostModuleItemProgressUpdate(self.model.id, CKIModuleItemCompletionRequirementMustView);
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                DDLogVerbose(@"AssignmentDetailViewController posting module item progress update after error marking External URL Module Item as viewed: %@", error.localizedDescription);
                CBIPostModuleItemProgressUpdate(self.model.id, CKIModuleItemCompletionRequirementMustView);
            }];
        }
    }

    return browser;
}

- (BOOL)tableViewController:(MLVCTableViewController *)controller shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return !self.lockedOut;
}

- (NSIndexPath *)tableViewController:(MLVCTableViewController *)controller willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.lockedOut ? nil : indexPath;
}

@end
