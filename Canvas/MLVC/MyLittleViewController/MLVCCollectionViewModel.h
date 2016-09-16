//
//  MLVCCollectionViewModel.h
//  MyLittleViewController
//
//  Created by derrick on 11/13/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MLVCViewModel.h"

@class MLVCCollectionViewController, MLVCCollectionController;

@protocol MLVCCollectionViewModel <MLVCViewModel>
@property (nonatomic) MLVCCollectionController *collectionController;

@optional
- (void)collectionViewControllerViewDidLoad:(MLVCCollectionViewController *)collectionViewController;

- (UICollectionReusableView *)collectionViewController:(UICollectionViewController *)controller viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;
@end

