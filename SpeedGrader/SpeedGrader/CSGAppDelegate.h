//
//  CSGAppDelegate.h
//  SpeedGrader
//
//  Created by Jason Larsen on 4/28/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDLogFileManagerDefault;

@interface CSGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong) DDLogFileManagerDefault *logFileManager;

@end