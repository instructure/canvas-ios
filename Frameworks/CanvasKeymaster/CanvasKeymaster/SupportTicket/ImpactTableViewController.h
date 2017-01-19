//
//  ImpactTableViewController.h
//  iCanvas
//
//  Created by Rick Roberts on 8/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SupportTicket.h"

@interface ImpactTableViewController : UITableViewController

@property (nonatomic, strong) SupportTicket *ticket;

@end
