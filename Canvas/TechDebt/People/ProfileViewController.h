//
//  ProfileViewController.h
//  iCanvas
//
//  Created by Jason Larsen on 5/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKUser;
@class CKCanvasAPI;

@interface ProfileViewController : UIViewController

@property CKCanvasAPI *canvasAPI;
@property (nonatomic) CKUser *user;
@property (nonatomic, copy) void (^profileImageSelected)(UIImage *newProfileImage);
@property (nonatomic, copy) UIViewController *(^settingsViewControllerFactory)();

@end
