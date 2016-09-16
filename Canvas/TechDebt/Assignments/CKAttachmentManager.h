//
//  CKAttachmentManager.h
//  CanvasKit
//
//  For use in Conversations/Messages to add attachments to messages
//  as well as discussions for inline media attachments
//
//  Created by Stephen Lottermoser on 4/18/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol CKAttachmentManagerDelegate;

typedef enum {
    CKAllowNoAttachments     = 0,
    CKAllowPhotoAttachments  = 1 << 0,
    CKAllowAudioAttachments  = 1 << 1,
    CKAllowVideoAttachments  = 1 << 2,
} CKAllowedAttachmentType;

@interface CKAttachmentManager : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<CKAttachmentManagerDelegate> delegate;

// An array of CKEmbeddedAttachment objects
@property (strong, nonatomic) NSArray * attachments;
// The number of attachments this manager is managing
@property (nonatomic, readonly) NSUInteger count;

// Default allows photo, video, and audio types
@property (nonatomic) CKAllowedAttachmentType allowedAttachmentTypes;

// Whether or not to add Messages-style rounded corners and gloss to thumbnails
@property (nonatomic) BOOL shouldApplyOverlaysToThumbs;

// When enabled, adds an item to the action sheet that the user can select to
// preview the attachments they've chosen so far. The delegate must implement 
// showAttachmentsForAttachmentManager: if this is set to YES. Default is NO.
@property (nonatomic) BOOL viewAttachmentsOptionEnabled;
@property (nonatomic, weak) UIViewController *presentFromViewController;

- (void)clearAttachments;

// iPad
- (void)showAttachmentPickerFromRect:(CGRect)rect
                              inView:(UIView *)view
            permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections
                      withSheetTitle:(NSString *)sheetTitle;
// iPhone
- (void)showAttachmentPickerFromViewController:(UIViewController *)viewController
                                withSheetTitle:(NSString *)sheetTitle;

@end



@protocol CKAttachmentManagerDelegate <NSObject>

// Called whenever the user completes the flow and actually chooses a new attachment
- (void)attachmentManager:(CKAttachmentManager *)manager didAddAttachmentAtIndex:(NSUInteger)index;


@optional
// The delegate should implement these if it cares about removal events.
- (void)attachmentManagerDidRemoveAllAttachments:(CKAttachmentManager *)manager;
- (void)attachmentManager:(CKAttachmentManager *)manager didRemoveAttachmentAtIndex:(NSUInteger)index;

// The delegate shoule implement this is viewAttachmentsOptionEnabled is set to YES.
- (void)showAttachmentsForAttachmentManager:(CKAttachmentManager *)manager;

@end
