//
//  CBIContentLockViewController.h
//  iCanvas
//
//  Created by derrick on 2/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "ContentLockViewController.h"

@class CBILockableViewModel;

@interface CBIContentLockViewController : ContentLockViewController
- (id)initWithViewModel:(CBILockableViewModel *)lockableViewModel;
@end
