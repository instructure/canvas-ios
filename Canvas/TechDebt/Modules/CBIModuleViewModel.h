//
//  CBIModuleViewModel.h
//  iCanvas
//
//  Created by derrick on 11/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"
#import "CBIColorfulModuleCell.h"

@class CKIModule;
@interface CBIModuleViewModel : CBIColorfulViewModel <CBIColorfulModuleViewModel>
@property (nonatomic) CKIModule *model;
@property (nonatomic) NSArray *prerequisiteModuleViewModels;
@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL selected;
@end
