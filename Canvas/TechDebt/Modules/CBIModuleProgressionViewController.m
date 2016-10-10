//
//  CBIModuleProgressionViewController.m
//  iCanvas
//
//  Created by Nathan Armstrong on 1/20/16.
//  Copyright © 2016 Instructure. All rights reserved.
//

#import "CBIModuleProgressionViewController.h"
#import "ThreadedDiscussionViewController.h"
#import "CBIModuleViewModel.h"
#import "CBIModuleItemViewModel.h"
#import "Router.h"
#import "CBIModuleProgressNotifications.h"
#import "CKIModule+ModuleProgression.h"
@import CanvasKeymaster;

@interface CBIModuleProgressionViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *prevButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *nextButton;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, strong) UIBarButtonItem *markDoneButton;

@property (nonatomic, strong) CKIModuleItem *nextModuleItem;
@property (nonatomic, strong) CKIModuleItem *prevModuleItem;

@property (nonatomic, strong, readwrite) UIViewController *childViewController;

@end

@implementation CBIModuleProgressionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self routeToViewModel:self.moduleItemViewModel];

    self.markDoneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Mark as Done", @"Button title for mark as done")
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(markAsDone:)];

    // disable markDoneButton for items that are already completed
    RAC(self, markDoneButton.enabled) = [RACObserve(self, moduleItemViewModel.model.completed) map:^id(NSNumber *completed) {
        return @(![completed boolValue]);
    }];

    // only show markDoneButton for the correct completionRequirement
    @weakify(self);
    [RACObserve(self, moduleItemViewModel.model.completionRequirement) subscribeNext:^(NSString *requirement) {
        @strongify(self);
        self.navigationItem.rightBarButtonItem = self.childViewController.navigationItem.rightBarButtonItem;
        if ([requirement isEqualToString:CKIModuleItemCompletionRequirementMustMarkDone]) {
            self.navigationItem.rightBarButtonItem = self.markDoneButton;
        }
    }];

    RAC(self, nextButton.enabled) = [RACObserve(self, nextModuleItem) map:^id(CKIModuleItem *item) {
        return @(item != nil);
    }];

    RAC(self, prevButton.enabled) = [RACObserve(self, prevModuleItem) map:^id(CKIModuleItem *item) {
        return @(item != nil);
    }];
}

- (void)setModuleItemViewModel:(CBIModuleItemViewModel *)moduleItemViewModel
{
    _moduleItemViewModel = moduleItemViewModel;
    self.nextModuleItem = [self.moduleItemViewModel.module moduleItemAfterModuleItem:moduleItemViewModel.model];
    self.prevModuleItem = [self.moduleItemViewModel.module moduleItemBeforeModuleItem:moduleItemViewModel.model];

    // Selects the current module in the list on iPad.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Because identifying this item can't be simple.
        NSString *itemID = moduleItemViewModel.model.itemID ?: moduleItemViewModel.model.id;
        if ([moduleItemViewModel.model.type isEqualToString:CKIModuleItemTypeExternalTool]) {
            itemID = [moduleItemViewModel.model.htmlURL absoluteString];
        }

        CBIPostProgressionMadeModuleItemActiveUpdate(itemID);
    }
}

- (CBIModuleItemViewModel *)nextModuleItemViewModel
{
    CBIModuleItemViewModel *viewModel = [CBIModuleItemViewModel new];
    viewModel.model = self.nextModuleItem;
    viewModel.module = self.moduleItemViewModel.module;
    return viewModel;
}

- (CBIModuleItemViewModel *)previousModuleItemViewModel
{
    CBIModuleItemViewModel *viewModel = [CBIModuleItemViewModel new];
    viewModel.model = self.prevModuleItem;
    viewModel.module = self.moduleItemViewModel.module;
    return viewModel;
}

- (IBAction)prevTapped:(id)sender
{
    [self routeToViewModel:[self previousModuleItemViewModel]];
}

- (IBAction)nextTapped:(id)sender
{
    [self routeToViewModel:[self nextModuleItemViewModel]];
}

- (void)routeToViewModel:(CBIModuleItemViewModel *)viewModel
{
    self.moduleItemViewModel = viewModel;
    CBIViewModel *destination = [viewModel viewModelForModuleItem];
    if (!destination) {
        [self embedChildViewController:[viewModel browserViewControllerForModuleItem]];
        return;
    }
    [[Router sharedRouter] routeFromController:self toViewModel:destination];
}


- (void)embedChildViewController:(UIViewController *)childViewController
{
    if (!childViewController) {
        return;
    }

    if (self.childViewController != nil) {
        UIViewController *oldViewController = self.childViewController;
        [oldViewController willMoveToParentViewController:nil];
        [oldViewController.view removeFromSuperview];
        [oldViewController removeFromParentViewController];
    }

    self.childViewController = childViewController;

    [self addChildViewController:childViewController];
    [self.contentView addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];

    if (childViewController.navigationItem.rightBarButtonItem) {
        self.navigationItem.rightBarButtonItem = childViewController.navigationItem.rightBarButtonItem;
    }

    UIView *childView = childViewController.view;
    childView.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1.0
                                                           constant:0]];
    // bottom
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:childView
                                                          attribute:NSLayoutAttributeBottom
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.contentView
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0]];
    // left and right
    [self.contentView addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"|[childView]|"
                               options:0
                               metrics:nil
                               views:NSDictionaryOfVariableBindings(childView)]];
}

- (void)markAsDone:(UIBarButtonItem *)sender
{
    [[[CKIClient currentClient] markModuleItemAsDone:self.moduleItemViewModel.model] subscribeError:^(NSError *error) {
        NSLog(@"What happened?");
    } completed:^{
        CBIPostModuleItemProgressUpdate(self.moduleItemViewModel.model.itemID, CKIModuleItemCompletionRequirementMustMarkDone);
    }];
}

@end
