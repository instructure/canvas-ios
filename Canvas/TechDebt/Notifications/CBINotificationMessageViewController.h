//
// Created by Jason Larsen on 1/17/14.
// Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKIActivityStreamItem;


@interface CBINotificationMessageViewController : UIViewController
@property (nonatomic, strong) CKIActivityStreamItem *streamItem;
@end