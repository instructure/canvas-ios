//
//  CBIColorfulViewModel.h
//  iCanvas
//
//  Created by derrick on 11/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <CanvasKit/CanvasKit.h>
#import "CBIViewModel.h"
#import <MyLittleViewController/MyLittleViewController.h>

@interface CBIColorfulViewModel : CBIViewModel <MLVCTableViewModel>

+ (id (^)(id))modelMappingBlockObservingTintColor:(RACSignal *)tintColor;

@property (nonatomic) NSString *name;
@property (nonatomic) UIImage *icon;
@property (nonatomic) UIColor *tintColor;
@property (nonatomic) NSString *subtitle;
@property (nonatomic) NSString *detail;
/**
 returns a signal of viewModel pages for this collection.
 */
@property (nonatomic, readonly) RACSignal *refreshViewModelsSignal;
@end
