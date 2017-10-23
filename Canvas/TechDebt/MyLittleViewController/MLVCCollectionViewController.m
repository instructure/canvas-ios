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
    
    

#import "MLVCCollectionViewController.h"
#import "MLVCCollectionViewCellViewModel.h"
#import "MLVCCollectionController.h"
#import "UICollectionView+MyLittleViewController.h"
#import "MLVCTableViewModel.h"

@interface MLVCCollectionViewController () <UICollectionViewDelegateFlowLayout>
@end

@implementation MLVCCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self.viewModel respondsToSelector:@selector(viewControllerViewDidLoad:)]) {
        [self.viewModel viewControllerViewDidLoad:self];
    }
    
    if ([self.viewModel respondsToSelector:@selector(collectionViewControllerViewDidLoad:)]) {
        [self.viewModel collectionViewControllerViewDidLoad:self];
    }
    
    if (self.viewModel) {
        [self.collectionView mlvc_observeCollectionController:_viewModel.collectionController];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.viewModel respondsToSelector:@selector(viewController:viewWillAppear:)]) {
        [self.viewModel viewController:self viewWillAppear:animated];
    }

    if ([self.viewModel respondsToSelector:@selector(refreshViewModelSignalForced:)]) {
        RACSignal *refreshSignal = [self.viewModel refreshViewModelSignalForced:NO];
        
        [refreshSignal subscribeCompleted:^{
            if ([self.viewModel conformsToProtocol:@protocol(MLVCTableViewModel)]) {
                id<MLVCTableViewModel> viewModel = (id<MLVCTableViewModel>) self.viewModel;
                if (viewModel.tableviewRefreshCompleted){
                    viewModel.tableviewRefreshCompleted();
                }
            }
        }];
    }
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if ([self.viewModel respondsToSelector:@selector(viewController:viewWillDisappear:)]) {
        [self.viewModel viewController:self viewWillDisappear:animated];
    }
}


- (void)setViewModel:(id<MLVCCollectionViewModel>)viewModel
{
    if (_viewModel == viewModel) {
        return;
    }
    
    _viewModel = viewModel;
    
    if (self.isViewLoaded)
    {
        if ([self.viewModel respondsToSelector:@selector(viewControllerViewDidLoad:)]) {
            [self.viewModel viewControllerViewDidLoad:self];
        }
        if ([self.viewModel respondsToSelector:@selector(collectionViewControllerViewDidLoad:)]) {
            [self.viewModel collectionViewControllerViewDidLoad:self];
        }

        [self.collectionView mlvc_observeCollectionController:_viewModel.collectionController];
        [self.collectionView reloadData];
    }
}

#pragma mark - UICollectionViewDataSource

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(240, 260);
}


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.viewModel.collectionController.groups count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    MLVCCollectionControllerGroup *group = self.viewModel.collectionController[section];
    return [group.objects count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCCollectionViewCellViewModel> item = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    return [item collectionViewController:self cellForItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<MLVCCollectionViewCellViewModel> item = [self.viewModel.collectionController objectAtIndexPath:indexPath];
    [item collectionViewController:self didSelectItemAtIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSAssert([self.viewModel respondsToSelector:@selector(collectionViewController:viewForSupplementaryElementOfKind:atIndexPath:)], @"The view model for your MLVCCollectionViewController must implement this method");
    
    return [self.viewModel collectionViewController:self viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPaht
{
    id<MLVCCollectionViewCellViewModel> item = [self.viewModel.collectionController objectAtIndexPath:indexPaht];

    if ([item respondsToSelector:@selector(collectionViewController:shouldDeselectItemAtIndexPath:)]) {
        return [item collectionViewController:self shouldDeselectItemAtIndexPath:indexPaht];
    }
    
    return YES;
}

- (UICollectionViewTransitionLayout *)collectionView:(UICollectionView *)collectionView transitionLayoutForOldLayout:(UICollectionViewLayout *)fromLayout newLayout:(UICollectionViewLayout *)toLayout
{
    UICollectionViewTransitionLayout *transitionLayout = [[UICollectionViewTransitionLayout alloc] initWithCurrentLayout:fromLayout nextLayout:toLayout];
    return transitionLayout;
}

@end
