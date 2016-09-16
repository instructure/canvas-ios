//
//  CKRichTextInputView.h
//  CanvasKit
//
//  Created by Stephen Lottermoser on 3/2/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CKCanvasAPI.h"
#import "CKAttachmentManager.h"

@protocol CKRichTextInputViewDelegate;
@class CKDiscussionEntry;

@interface CKRichTextInputView : UIView

@property (nonatomic, weak) id<CKRichTextInputViewDelegate> delegate;
@property (strong, nonatomic) CKAttachmentManager * attachmentManager;

@property (nonatomic) CGFloat minimumHeight;
@property (nonatomic) CGFloat maximumHeight;
@property (nonatomic, strong) CKDiscussionEntry *entry;
@property (nonatomic) BOOL showsAttachmentButton;
@property (nonatomic) BOOL showPostButton;
@property (nonatomic) NSString *initialText;
@property (nonatomic) NSString *placeholderText;
@property (nonatomic, strong) void (^finishedLoadingWebViewBlock)();
@property (nonatomic) NSString *attachmentSheetTitle;
@property (nonatomic) UIImage *attachmentButtonImage;
@property (strong, nonatomic) IBOutlet UIWebView *webView;

// Setting this to CKAllowNoAttachments hides the attachment button
// Default allows photo, video, and audio types
@property (nonatomic) CKAllowedAttachmentType allowedAttachmentTypes;

@property (readonly) BOOL isEmpty;

@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (void)dismissKeyboard;
- (NSUInteger)addImage:(NSString *)pathToImage ofHeight:(CGFloat)height;
- (void)clearContents;
- (void)resize;
- (BOOL)hasContent;

- (IBAction)tappedPostCommentButton:(id)sender;
- (IBAction)addAttachment:(id)sender;

- (NSString *)replaceImagesWithThumbnailsInHTML:(NSString *)html;

// template method to allow use of alternate nib file
- (void)loadNib;

@end

@protocol CKRichTextInputViewDelegate <NSObject>

- (void)resizeRichTextInputViewToHeight:(CGFloat)height;

// The attachments array is an array of CKEmbeddedAttachment objects, or nil if none are in the comment box
- (void)richTextView:(CKRichTextInputView *)inputView postComment:(NSString *)comment withAttachments:(NSArray*)attachments andCompletionBlock:(CKSimpleBlock)block;

@end