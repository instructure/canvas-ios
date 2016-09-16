//
//  CBISplitViewController.h
//  iCanvas
//
//  Created by derrick on 10/31/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Feel free to subclass this.
 
 Just set the master and detail view controllers.
 */
@interface CBISplitViewController : UIViewController

@property (nonatomic) BOOL isDetailToMasterTransition;

@property (nonatomic) UIViewController *master;
@property (nonatomic) UIViewController *detail;

@property (nonatomic, readonly) NSLayoutConstraint *masterWidthConstraint, *masterXOffsetConstraint, *detailWidthConstraint, *detailXOffsetConstraint;

- (void)layoutMasterAndDetailViews;

- (void)pushNextDetailViewController:(UIViewController *)nextDetailViewController animated:(BOOL)animated;

@end


@interface UIViewController (CBISplitViewController)
@property (nonatomic, readonly) CBISplitViewController *cbi_splitViewController;
@end