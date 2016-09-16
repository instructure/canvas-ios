//
//  CBIFileViewModel.h
//  iCanvas
//
//  Created by rroberts on 1/8/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBILockableViewModel.h"
@import MyLittleViewController;

@interface CBIFileViewModel : CBILockableViewModel

@property (nonatomic, assign) int index;
@property (nonatomic, strong) CKIFile *model;
@property (nonatomic, assign) BOOL canEdit;

@end
