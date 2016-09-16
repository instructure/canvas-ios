//
//  DiscussionChildCountIndicatorView.h
//  iCanvas
//
//  Created by BJ Homer on 5/21/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DiscussionChildCountIndicatorView : UIView

@property int totalCount;
@property int unreadCount;
@property (readonly) CGFloat width;

@end
