//
//  CKCommentViewController.h
//  CanvasKit
//
//  Created by Mark Suman on 5/3/10.
//  Copyright 2010 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKSubmission,CKSubmissionComment,CKCommentAttachment, CKCanvasAPI;

@protocol CKCommentViewControllerDelegate <NSObject>
@optional
- (void)commentViewController:(id)sender didSelectAttachment:(CKCommentAttachment *)attachment;
- (void)commentViewController:(id)sender didPostNewAttachmentForSubmission:(CKSubmission *)submission;
@end



extern NSString *CKCommentsViewHeightDidChangeNotification;

@interface CKCommentViewController : UIViewController

@property CGFloat commentsHeight;
@property (strong) CKCanvasAPI *canvasAPI;
@property (nonatomic, strong) CKSubmission *submission;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *placeholderActivityView;

@property (weak) id<CKCommentViewControllerDelegate> delegate;

@property (readonly) BOOL hasPendingContent;

- (void)reload;
- (void)reloadIfVisible;
- (void)loadComment:(CKSubmissionComment *)comment;
- (void)scrollCommentsViewToBottom:(BOOL)force;
- (void)setCommentsHeightFromJavascript;
- (void)resizeCommentsPopover:(NSNotification *)note;
- (IBAction)flipInputPanel:(id)sender;

@end
