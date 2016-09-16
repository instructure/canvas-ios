//
//  CKURLPreviewViewController.h
//  CanvasKit
//
//  Created by BJ Homer on 4/2/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <QuickLook/QuickLook.h>

@interface CKURLPreviewViewController : QLPreviewController

@property (strong) NSString *title;
@property (nonatomic, strong) NSURL *url;
@property (assign) UIBarStyle modalBarStyle;
@end
