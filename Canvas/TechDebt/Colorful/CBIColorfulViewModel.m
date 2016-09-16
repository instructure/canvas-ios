//
//  CBIColorfulViewModel.m
//  iCanvas
//
//  Created by derrick on 11/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"
#import "EXTScope.h"

@interface CBIColorfulViewModel ()
@property (nonatomic) RACSignal *currentRequestSignal;
@property (nonatomic) RACDisposable *currentRequestDisposable;
@end

@implementation CBIColorfulViewModel
@synthesize collectionController;
@synthesize tableviewRefreshCompleted;

+ (id (^)(id))modelMappingBlockObservingTintColor:(RACSignal *)tintColor
{
    return ^(CKIModel *model) {
        CBIColorfulViewModel *colorful = [self viewModelForModel:model];
        RAC(colorful, tintColor) = tintColor;
        return colorful;
    };
}


#pragma mark - MLVCCollectionViewModel

- (void)tableViewControllerViewDidLoad:(MLVCTableViewController *)tableViewController
{
    [tableViewController.tableView registerNib:[UINib nibWithNibName:@"CBIColorfulCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"CBIColorfulCell"];
}

- (void)viewControllerViewDidLoad:(UIViewController *)viewController
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && [viewController isKindOfClass:[MLVCTableViewController class]]){
        MLVCTableViewController *tableViewController = (MLVCTableViewController *)viewController;
        @weakify(tableViewController);
        self.tableviewRefreshCompleted = ^() {
            @strongify(tableViewController);
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, tableViewController.tableView);
        };
    }
    [super viewControllerViewDidLoad:viewController];
}

- (RACSignal *)refreshViewModelSignalForced:(BOOL)forced
{
    // if it's forced, cancel the previous request if any
    if (forced) {
        [self.currentRequestDisposable dispose];
        self.currentRequestDisposable = nil;
        self.currentRequestSignal = nil;
    }
    // else if we are already refreshing
    else if (self.currentRequestSignal) {
        return self.currentRequestSignal;
    }
    // else if we already have data
    else if ([self.collectionController.groups count]) {
        return [RACSignal empty];
    }
    
    @weakify(self);
    self.currentRequestSignal = [self.refreshViewModelsSignal replay];
    
    __block BOOL hasResetCollection1Time = NO;
    self.currentRequestDisposable = [self.currentRequestSignal subscribeNext:^(NSArray *viewModels) {
        @strongify(self);
        if (!hasResetCollection1Time) {
            [self.collectionController removeAllObjectsAndGroups];
            hasResetCollection1Time = YES;
        }
        [self.collectionController insertObjects:viewModels];
    } completed:^{
        @strongify(self);
        self.currentRequestSignal = nil;
        self.currentRequestDisposable = nil;
    }];
    
    return self.currentRequestSignal;
}

- (RACSignal *)refreshViewModelsSignal
{
    // should be overriden by subclasses
    return [RACSignal empty];
}

- (void)dealloc
{
    [self.currentRequestDisposable dispose];
}

@end
