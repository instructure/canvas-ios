//
// Copyright (C) 2016-present Instructure, Inc.
//   
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
