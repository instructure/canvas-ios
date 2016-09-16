//
//  CBIFolderViewModel.h
//  iCanvas
//
//  Created by rroberts on 1/9/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBILockableViewModel.h"

@interface CBIFolderViewModel : CBILockableViewModel

@property (nonatomic, assign) int index;
@property (nonatomic, strong) CKIFolder *model;
@property (nonatomic) BOOL canEdit;

@end
