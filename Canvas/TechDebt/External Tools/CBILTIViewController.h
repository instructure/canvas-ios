    //
//  CBILTIViewController.h
//  iCanvas
//
//  Created by Derrick Hathaway on 3/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "LTIViewController.h"


@class CBIExternalToolViewModel;

@interface CBILTIViewController : LTIViewController
@property (nonatomic) CBIExternalToolViewModel *viewModel;


@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomInsetConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewBottomInsetContstant;

@end
