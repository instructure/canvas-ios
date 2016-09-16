//
//  CKTextCommentInputView.m
//  CanvasKit
//
//  Created by BJ Homer on 9/16/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKTextCommentInputView.h"
#import "UIImage+CanvasKit1.h"
#import <QuartzCore/QuartzCore.h>

@implementation CKTextCommentInputView
@synthesize inputCommentTextView;
@synthesize postTextCommentButton;
@synthesize flipToMediaCommentButton;
@synthesize textCommentActivityView;

- (id)init
{
    
    NSArray *topLevelObjects = [[UINib nibWithNibName:@"TextCommentView" bundle:[NSBundle bundleForClass:[self class]]] instantiateWithOwner:nil options:nil];
    
    self = topLevelObjects[0];
    
    // Style the input text field
    self.inputCommentTextView.layer.cornerRadius = 5;
    self.inputCommentTextView.layer.borderWidth = 1;
    self.inputCommentTextView.layer.borderColor = [[UIColor grayColor] CGColor];
    
    self.postTextCommentButton.style = CKButtonStyleTextComment;
    self.flipToMediaCommentButton.style = CKButtonStyleTextComment;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [self.flipToMediaCommentButton setImage:[UIImage canvasKit1ImageNamed:@"button-fliptomedia-camera"] forState:UIControlStateNormal];
    }
    
    [self.postTextCommentButton setTitle:NSLocalizedString(@"Post Comment",nil) forState:UIControlStateNormal];
    self.postTextCommentButton.accessibilityLabel = NSLocalizedString(@"Post Comment", nil);
    self.postTextCommentButton.accessibilityHint = NSLocalizedString(@"Posts your comment", nil);
    
    self.flipToMediaCommentButton.accessibilityLabel = NSLocalizedString(@"Media Comment", nil);
    self.flipToMediaCommentButton.accessibilityHint = NSLocalizedString(@"Switches to media comment mode", nil);
    
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
