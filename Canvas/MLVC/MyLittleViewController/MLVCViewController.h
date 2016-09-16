//
//  MLVCViewController.h
//  MyLittleViewController
//
//  Created by derrick on 11/15/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLVCViewModel.h"

@interface MLVCViewController : UIViewController
@property (nonatomic) IBOutlet id<MLVCViewModel> viewModel;
@end
