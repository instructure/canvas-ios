
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
