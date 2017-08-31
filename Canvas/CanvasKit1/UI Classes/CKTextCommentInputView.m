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
