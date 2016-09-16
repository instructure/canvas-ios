//
//  LTIViewController.h
//  iCanvas
//
//  Created by derrick on 6/24/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKIExternalTool;
@interface LTIViewController : UIViewController
@property (nonatomic) CKIExternalTool *externalTool;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end
