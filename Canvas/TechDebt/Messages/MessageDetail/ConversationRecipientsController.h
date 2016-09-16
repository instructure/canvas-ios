//
//  ConversationRecipientsController.h
//  iCanvas
//
//  Created by BJ Homer on 10/7/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
@import CanvasKit;

@class CKIConversationRecipient;
@class JSTokenField;
@class ConversationRecipientsController;

@protocol ConversationRecipientsControllerDelegate <NSObject>

- (BOOL)isRecipientSelected:(CKIConversationRecipient *)recipient;
- (BOOL)isRecipientSelectable:(CKIConversationRecipient *)recipient;

@optional

- (void)recipientsControllerDidChangeSelections:(ConversationRecipientsController *)controller;
- (void)recipientsController:(ConversationRecipientsController *)controller didPushNewRecipientsController:(ConversationRecipientsController *)newController;
- (void)recipientsController:(ConversationRecipientsController *)controller willPopToRecipientsController:(ConversationRecipientsController *)previousController;
- (void)recipientsController:(ConversationRecipientsController *)controller saveRecipients:(NSArray *)recipients;

@end



@interface ConversationRecipientsController : UITableViewController

@property (weak, nonatomic) IBOutlet JSTokenField *tokenField;

@property (nonatomic, copy) NSString *searchString;
@property (nonatomic, strong) CKIConversationRecipient *searchContext;
@property (weak) id<ConversationRecipientsControllerDelegate> delegate;

@property (assign) BOOL allMembersAreImplicitlySelected;

@property (assign) BOOL popoverMode; // Hides the "Done" button

@property (assign) BOOL allowsSelection; // default = YES
@property (assign) BOOL showsCheckmarksForSelectedItems; //default = YES
@property (assign) BOOL showsTokenField; // default = YES

// Recipients that have been selected during this "session"
// You can set this to an initial array if you want to prepopulate
// recipients that have been selected. These recipients will show in
// the token field, if it is present.
@property (nonatomic) NSArray *selectedRecipients;


// If this is set, this is what will be shown when there is no searchString
// and no searchContext.
@property (copy, nonatomic) NSArray *staticResults;

@end


@interface CKIConversationRecipient (ContextedNames)
@property (copy) NSString *contextedName;
@end
