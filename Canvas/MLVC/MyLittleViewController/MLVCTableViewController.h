//
//  MLVCTableViewController.h
//  MyLittleViewController
//
//  Created by derrick on 10/4/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLVCTableViewModel.h"
@class RACSignal;

@interface MLVCTableViewController : UITableViewController
@property (nonatomic) IBOutlet id<MLVCTableViewModel> viewModel;

@property (nonatomic, readonly) RACSignal *selectedCellViewModelSignal;
@property (nonatomic, readonly) RACSignal *tableViewDidAppearSignal;
@property (nonatomic, strong) id customRefreshControl;

- (void)refreshFromRefreshControl:(id)refreshControl;
@end
