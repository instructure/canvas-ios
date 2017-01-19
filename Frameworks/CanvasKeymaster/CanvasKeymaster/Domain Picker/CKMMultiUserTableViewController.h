//
//  CBIMultiUserTableViewController.h
//  iCanvas
//
//  Created by Brandon Pluim on 4/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
@import ReactiveObjC;

@interface CKMMultiUserTableViewController : UITableViewController

- (RACSignal *)selectedUserSignal;

@end
