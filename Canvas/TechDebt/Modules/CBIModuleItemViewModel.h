//
//  CBIModuleItemViewModel.h
//  iCanvas
//
//  Created by derrick on 11/8/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBIColorfulViewModel.h"
#import "CBIColorfulModuleCell.h"
#import "WebBrowserViewController.h"

@class CKIModuleItem;

@interface CBIModuleItemViewModel : CBIColorfulViewModel<CBIColorfulModuleViewModel>
@property (nonatomic) CKIModuleItem *model;

@property (nonatomic, weak) CKIModule *module;

@property (nonatomic) NSInteger index;

- (WebBrowserViewController *)browserViewControllerForModuleItem;
- (CBIViewModel *)viewModelForModuleItem;
@end
