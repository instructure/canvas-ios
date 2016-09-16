//
//  CBIMessagesSplitViewController.h
//  iCanvas
//
//  Created by derrick on 11/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CBISplitViewController.h"

@class CBIMessagesListViewModel;

@interface CBIMessagesSplitViewController : CBISplitViewController
@property (nonatomic) CBIMessagesListViewModel *viewModel;
@end
