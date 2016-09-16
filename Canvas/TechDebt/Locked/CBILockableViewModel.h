//
//  CBILockableViewModel.h
//  iCanvas
//
//  Created by derrick on 2/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"

@interface CBILockableViewModel : CBIColorfulViewModel
@property (nonatomic) CKILockableModel *model;
@property (nonatomic) NSString *lockedItemName;
@property (nonatomic) UIImage *unlockedIcon;
@end
