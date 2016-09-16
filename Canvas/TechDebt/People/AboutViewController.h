//
//  AboutViewController.h
//  iCanvas
//
//  Created by nlambson on 7/31/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKUser;

@interface AboutViewController : UITableViewController
@property (nonatomic) CKCanvasAPI *canvasAPI;
@property (nonatomic) CKUser *user;
@end
