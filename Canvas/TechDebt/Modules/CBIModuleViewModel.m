//
//  CBIModuleViewModel.m
//  iCanvas
//
//  Created by derrick on 11/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIModuleViewModel.h"
@import ReactiveCocoa;
#import "CBIModuleItemViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "Router.h"
#import "EXTScope.h"
#import "CBIModuleProgressNotifications.h"
@import CanvasKeymaster;

@interface CBIModuleViewModel ()
@property (nonatomic) NSMutableDictionary *moduleItemsByID;
@property (nonatomic) BOOL hasCompletionRequirement;
@end

@implementation CBIModuleViewModel
@synthesize collectionController;
@synthesize state;
@synthesize lockedOut;
@synthesize selected;

static NSNumber *(^colorfulModuleStateForState)(NSString *) = ^NSNumber *(NSString *moduleState) {
    if ([moduleState isEqualToString:CKIModuleStateLocked]) {
        return @(CBIColorfulModuleViewModelStateLocked);
    } else if ([moduleState isEqualToString:CKIModuleStateUnlocked]) {
        return @(CBIColorfulModuleViewModelStateUnlocked);
    } else if ([moduleState isEqualToString:CKIModuleStateStarted]) {
        return @(CBIColorfulModuleViewModelStateIncomplete);
    } else if ([moduleState isEqualToString:CKIModuleStateCompleted]) {
        return @(CBIColorfulModuleViewModelStateCompleted);
    }
    return @(CBIColorfulModuleViewModelStateNone);
};

- (id)init
{
    self = [super init];
    if (self) {
        RAC(self, name) = RACObserve(self, model.name);
        RAC(self, subtitle) = [RACObserve(self, model.unlockAt) map:^id(id value) {
            if (! value) {
                return @"";
            }
            NSDateFormatter *formatter = [NSDateFormatter new];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            return [NSString stringWithFormat:NSLocalizedString(@"Locked until %@", nil), [formatter stringFromDate:value]];
        }];
        RAC(self, viewControllerTitle) = RACObserve(self, model.name);
        self.moduleItemsByID = [NSMutableDictionary dictionary];
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:^id(id object) {
            return [object isKindOfClass:[CBIModuleViewModel class]] ? @(0) : @(1);
        } groupTitleBlock:^NSString *(id object) {
            return [object isKindOfClass:[CBIModuleViewModel class]] ? @"Prerequisite Modules" : @"Module Items";
        } sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshModuleStatus:) name:CBIModuleProgressUpdatedNotification object:nil];
        
        RAC(self, state) = [RACSignal combineLatest:@[RACObserve(self, hasCompletionRequirement), [RACObserve(self, model.state) map:colorfulModuleStateForState]] reduce:^id (NSNumber *hasRequirement, NSNumber *moduleState) {
            if ([moduleState integerValue] == CBIColorfulModuleViewModelStateCompleted && ![hasRequirement boolValue]) {
                return @(CBIColorfulModuleViewModelStateNone);
            }
            return moduleState;
        }];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshModuleStatus:(NSNotification *)note
{
    NSArray *moduleItems = self.model.items;
    [[[CKIClient currentClient] refreshModel:self.model parameters:nil] subscribeCompleted:^{
        self.model.items = moduleItems;
    }];
}

- (void)tableViewControllerViewDidLoad:(MLVCTableViewController *)tableViewController
{
    [tableViewController.tableView registerNib:[UINib nibWithNibName:@"CBIColorfulModuleCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"CBIColorfulCell"];
    [tableViewController.tableView registerNib:[UINib nibWithNibName:@"CBIModuleItemSubheaderCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"CBIModuleItemSubheaderCell"];
}

#pragma mark - sync

- (void)setupPermissionsForModuleItems:(NSArray *)allItems
{
    CKIModule *module = self.model;
    RACSignal *prevIncomplete = [RACSignal return:@NO];
    for (CBIModuleItemViewModel *current in allItems) {
        self.hasCompletionRequirement = self.hasCompletionRequirement || current.model.completionRequirement != nil;
        
        RACSignal *moduleLocked = [RACObserve(module, state) map:^id(NSString *aState) {
            return @([aState isEqualToString:CKIModuleStateLocked]);
        }];
        
        RAC(current, lockedOut) = [[RACSignal combineLatest:@[prevIncomplete, moduleLocked]] or];
        
        if (module.requireSequentialProgress) {
            prevIncomplete = [[RACSignal combineLatest:@[prevIncomplete, [RACSignal combineLatest:@[RACObserve(current, model.completionRequirement), RACObserve(current, model.completed)] reduce:^id(NSString *requirement, NSNumber *completed) {
                return @(requirement && ![completed boolValue]);
            }]]] or];
        }
    }
}


- (RACSignal *)refreshViewModelsSignal {
    
    if (self.model == nil) {
        return [RACSignal empty];
    }
    
    __block NSInteger index = 0;
    NSMutableArray *allViewModels = [NSMutableArray array];
    NSMutableArray *allItems = [NSMutableArray array];
    @weakify(self);
    RACSignal *allItemsSignal = [[[[CKIClient currentClient] fetchModuleItemsForModule:self.model] map:^id(NSArray *items) {
        return [[items.rac_sequence map:^id(CKIModuleItem *moduleItem) {
            @strongify(self);
            [allItems addObject:moduleItem];
            CBIModuleItemViewModel *viewModel = [CBIModuleItemViewModel new];
            viewModel.model = moduleItem;
            viewModel.module = self.model;
            RAC(viewModel, tintColor) = RACObserve(self, tintColor);
            viewModel.index = index++;
            [allViewModels addObject:viewModel];
            return viewModel;
        }] array];
    }] replay];

    CKICourse *course = (CKICourse *)self.model.context;
    __block BOOL isStudent = NO;
    [course.enrollments enumerateObjectsUsingBlock:^(CKIEnrollment *enrollment, NSUInteger idx, BOOL *stop) {
        isStudent = *stop = enrollment.isStudent;
    }];
    
    if (isStudent) {
        [allItemsSignal subscribeCompleted:^{
            @strongify(self);
            [self setupPermissionsForModuleItems:allViewModels];
        }];
    }

    [allItemsSignal subscribeCompleted:^{
        self.model.items = allItems;
    }];

    return [[RACSignal return:self.prerequisiteModuleViewModels] concat:allItemsSignal];
}

@end
