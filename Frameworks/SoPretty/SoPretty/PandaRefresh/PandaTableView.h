//
//  PandaTableView.h
//  Pretty
//
//  Created by Nathan Perry on 5/22/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PandaTableView : UITableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style target:(id)target action:(SEL)action topLayoutGuideConstant:(CGFloat)topLayout;
-(instancetype) initWithFrame:(CGRect)frame style:(UITableViewStyle)style target:(id) target action:(SEL) action;

/**
 Programmatically show the panda. If invokeTarget is set to YES, also call the default
 refresh action. If set to NO, just shows the animation.
 */
-(void)startLoadingAndInvokeTarget:(BOOL) invokeTarget;
-(void)stopLoading;
-(void)stopLoadingWithCompletion:(void (^)())completion;
-(void)setToIdle;

@end
