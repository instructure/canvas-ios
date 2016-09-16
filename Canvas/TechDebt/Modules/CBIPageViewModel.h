//
//  CBIPageViewModel.h
//  iCanvas
//
//  Created by rroberts on 1/7/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBILockableViewModel.h"
@import PageKit;

@interface CBIPageViewModel : CBILockableViewModel

@property (nonatomic) int index;
@property (nonatomic, strong) Page *model;
@property (nonatomic) BOOL frontPage;

@end
