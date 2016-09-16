//
//  CBIMessagesListViewModel.h
//  iCanvas
//
//  Created by derrick on 11/22/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MyLittleViewController;

@interface CBIMessagesListViewModel : NSObject <MLVCTableViewModel>
@property (nonatomic) NSUInteger unreadMessagesCount;

- (void)badgeTabBarItem:(UITabBarItem *)tabBarItem;
@end
