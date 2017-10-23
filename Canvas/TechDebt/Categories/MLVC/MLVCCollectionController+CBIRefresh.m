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
    
    

#import <TechDebt/MyLittleViewController.h>
@import ReactiveObjC;

typedef id<MLVCViewModel> (^ViewModelFactory)(id model);
typedef void (^ViewModelUpdateBlock)(id<MLVCViewModel> existingViewModel, id model);
typedef id (^IdentityBlock)(id);

@implementation MLVCCollectionController (CBIRefresh)

- (NSIndexPath *)indexPathForObject:(id)object {
    id groupID = self.groupByBlock(object);
    NSUInteger groupIndex = [[self.groups valueForKey:@"id"] indexOfObject:groupID inSortedRange:NSMakeRange(0, self.groups.count) options:NSBinarySearchingFirstEqual usingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    MLVCCollectionControllerGroup *group = self[groupIndex];
    
    
    NSUInteger objectIndex = [group.objects indexOfObject:object];
    return [NSIndexPath indexPathForRow:objectIndex inSection:groupIndex];
}

- (RACTuple *)refreshCollectionWithModelSignal:(RACSignal *)modelSignal modelIDBlock:(IdentityBlock)modelIDBlock viewModelIDBlock:(IdentityBlock)viewModelIDBlock viewModelUpdateBlock:(ViewModelUpdateBlock)viewModelUpdateBlock viewModelFactoryBlock:(ViewModelFactory)factoryBlock;
{
    NSArray *existing = [self.groups.rac_sequence flattenMap:^__kindof RACStream *(MLVCCollectionControllerGroup *group) {
        return group.objects.rac_sequence;
    }].array;
    
    NSMutableDictionary *viewModelsByID = [NSMutableDictionary dictionaryWithObjects:existing forKeys:[existing.rac_sequence map:viewModelIDBlock].array];
    
    @weakify(self);
    RACDisposable *disposable = [modelSignal subscribeNext:^(NSArray *page) {
        @strongify(self);
        NSMutableArray *viewModelsToInsert = [NSMutableArray array];
        
        // update
        [page enumerateObjectsUsingBlock:^(id model, NSUInteger idx, BOOL *stop) {
            id viewModelIdentity = modelIDBlock(model);
            
            id<MLVCViewModel> existingViewModel = viewModelsByID[viewModelIdentity];
            if (existingViewModel != nil) {
                viewModelUpdateBlock(existingViewModel, model);
                [viewModelsByID removeObjectForKey:viewModelIdentity];
            } else {
                [viewModelsToInsert addObject:factoryBlock(model)];
            }
        }];
        
        // insert
        [self insertObjects:viewModelsToInsert];
    } completed:^{
        [self removeObjectsAtIndexPaths:[[viewModelsByID allValues].rac_sequence map:^id(id value) {
            @strongify(self);
            return [self indexPathForObject:value];
        }].array];
    }];
    
    return RACTuplePack(modelSignal, disposable);
}

@end
