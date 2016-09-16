//
//  MLVCCollectionController+CBIRefresh.m
//  iCanvas
//
//  Created by derrick on 2/6/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "MLVCCollectionController+CBIRefresh.h"
#import "EXTScope.h"

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

- (RACTuple *)refreshCollectionWithModelSignal:(RACSignal *)modelSignal modelIDBlock:(IdentityBlock)modelIDBlock viewModelIDBlock:(IdentityBlock)viewModelIDBlock viewModelUpdateBlock:(void (^)(id<MLVCViewModel> existingViewModel, id model))viewModelUpdateBlock viewModelFactoryBlock:(id<MLVCViewModel> (^)(id model))factoryBlock;
{
    NSArray *existing = [self.groups.rac_sequence flattenMap:^RACStream *(MLVCCollectionControllerGroup *group) {
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
