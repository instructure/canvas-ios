//
//  ConversationViewController.h
//  iCanvas
//
//  Created by BJ Homer on 10/19/11.
//  Copyright (c) 2011 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CKConversation;

@protocol ConversationViewControllerDelegate <NSObject>
- (void)didPostToConversations:(NSArray *)conversations;
@end


@interface ConversationViewController : UIViewController

@property (strong) CKConversation *conversation;
@property (weak) id<ConversationViewControllerDelegate> delegate;
@property (nonatomic) IBOutlet UIWebView *conversationWebView;

@property (nonatomic) NSMutableArray *recipients;


- (IBAction)sendMessage:(id)sender;
- (IBAction)showRecipientsTable;
@end
