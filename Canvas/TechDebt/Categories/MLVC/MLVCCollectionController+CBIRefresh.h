//
//  MLVCCollectionController+CBIRefresh.h
//  iCanvas
//
//  Created by derrick on 2/6/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

@import MyLittleViewController;

typedef NSString *(^IdentityBlock)(id object);

@interface MLVCCollectionController (CBIRefresh)

- (RACTuple *)refreshCollectionWithModelSignal:(RACSignal *)modelSignal modelIDBlock:(IdentityBlock)modelIDBlock viewModelIDBlock:(IdentityBlock)viewModelIDBlock viewModelUpdateBlock:(void (^)(id<MLVCViewModel> existingViewModel, id model))viewModelUpdateBlock viewModelFactoryBlock:(id<MLVCViewModel> (^)(id model))factoryBlock;

@end
