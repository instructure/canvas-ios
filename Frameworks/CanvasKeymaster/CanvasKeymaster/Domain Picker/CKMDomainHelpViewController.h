//
//  CKMDomainHelpViewController.h
//  CanvasKeymaster
//
//  Created by Brandon Pluim on 8/13/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CKMDomainHelpViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *cancelButton;
@property (nonatomic, strong) IBOutlet UIWebView *webview;

+ (instancetype)instantiateFromStoryboard;

@end
