//
//  FileViewController.h
//  iCanvas
//
//  Created by BJ Homer on 7/24/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKUploadProgressToolbar, CKCanvasAPI, CKContextInfo, CKAttachment;

@interface FileViewController : UIViewController

// needed to load file on own
@property CKCanvasAPI *canvasAPI;
@property CKContextInfo *contextInfo;
@property (nonatomic) CKAttachment *file;
@property uint64_t fileIdent;

@property (nonatomic) float downloadProgress;
@property (nonatomic, copy) NSURL *url;
@property CKUploadProgressToolbar *progressToolbar;
@property (nonatomic) BOOL showsCancelMessage;

@property (nonatomic, assign) BOOL showsInteractionButton;

- (void)showDownloadError:(NSError *)error;

@end
