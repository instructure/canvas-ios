//
//  CBIModulesViewModel.m
//  iCanvas
//
//  Created by derrick on 11/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIModulesTabViewModel.h"
#import "CBIModuleViewModel.h"
#import <CanvasKit/CanvasKit.h>
#import "Router.h"
@import CanvasKeymaster;

@implementation CBIModulesTabViewModel

- (id)init
{
    self = [super init];
    if (self) {
        self.collectionController = [MLVCCollectionController collectionControllerGroupingByBlock:nil groupTitleBlock:nil sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]]];
        self.viewControllerTitle = NSLocalizedString(@"Modules", @"title for the modules tab");
    }
    return self;
}

- (void)tableViewControllerViewDidLoad:(MLVCTableViewController *)tableViewController
{
    [tableViewController.tableView registerNib:[UINib nibWithNibName:@"CBIColorfulModuleCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"CBIColorfulCell"];
}

#pragma mark - syncing

- (RACSignal *)refreshViewModelsSignal {
    __block NSInteger index = 0;
    NSMutableDictionary *allViewModels = [NSMutableDictionary new];
    RACSignal *allViewModelsSignal = [[[[CKIClient currentClient] fetchModulesForCourse:(CKICourse *)self.model.context] map:^id(NSArray *modules) {
        return [[[modules rac_sequence] map:^id(CKIModule *module) {
            CBIModuleViewModel *viewModel = [CBIModuleViewModel new];
            viewModel.model = module;
            RAC(viewModel, tintColor) = RACObserve(self, tintColor);
            viewModel.index = index++;
            
            allViewModels[module.id] = viewModel;
            return viewModel;
        }] array];
    }] replay];
    
    [allViewModelsSignal subscribeCompleted:^{
        [allViewModels enumerateKeysAndObjectsUsingBlock:^(id key, CBIModuleViewModel *moduleViewModel, BOOL *stop) {
            NSMutableArray *viewModels = [NSMutableArray array];
            for (NSString *prereq in moduleViewModel.model.prerequisiteModuleIDs) {
                NSString *moduleID = [NSString stringWithFormat:@"%@", prereq];
                CBIModuleViewModel *prereq = allViewModels[moduleID];
                if (prereq) {
                    [viewModels addObject:prereq];
                }
            }
            moduleViewModel.prerequisiteModuleViewModels = [viewModels copy];
            [moduleViewModel refreshViewModelSignalForced:YES];
        }];
    }];
    
    return allViewModelsSignal;
}

@end
