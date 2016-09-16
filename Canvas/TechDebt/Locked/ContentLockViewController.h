//
//  ContentLockViewController.h
//  iCanvas
//
//  Created by Jason Larsen on 5/9/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKContentLock, CKCourse, CKContextInfo;

@interface ContentLockViewController : UIViewController
- (id)initWithContentLock:(CKContentLock *)contentLock itemName:(NSString *)name inContext:(CKContextInfo *)contextInfo;
- (void)lockViewController:(UIViewController *)view;
@end
