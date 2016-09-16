//
//  CBIModuleItemCell.h
//  iCanvas
//
//  Created by Derrick Hathaway on 3/25/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBIColorfulCell.h"

typedef NS_ENUM(NSInteger, CBIColorfulModuleViewModelState) {
    CBIColorfulModuleViewModelStateNone,
    CBIColorfulModuleViewModelStateLocked,
    CBIColorfulModuleViewModelStateUnlocked,
    CBIColorfulModuleViewModelStateIncomplete,
    CBIColorfulModuleViewModelStateCompleted
};

@protocol CBIColorfulModuleViewModel <NSObject>
@property (nonatomic) BOOL lockedOut;
@property (nonatomic) CBIColorfulModuleViewModelState state;
@property (nonatomic) BOOL selected;
@end

@interface CBIColorfulModuleCell : CBIColorfulCell
@property (nonatomic) CBIColorfulViewModel<CBIColorfulModuleViewModel> *viewModel;
@end
