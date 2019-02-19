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
    
    

#import "CKStylingButton.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+CanvasKit1.h"

@interface CKStylingButton ()

- (void)stylizeButtonForDefault;
- (void)stylizeButtonForTextComment;
- (void)stylizeButtonForMediaComment;
- (void)stylizeButtonForVideoOverlay;
- (void)stylizeButtonForLogin;

@end


@implementation CKStylingButton

@synthesize style;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 1.0f;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity = 0.7;
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.style = CKButtonStyleDefault;
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 1.0f;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity = 0.7;
        self.layer.shadowRadius = 5.0;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.style = CKButtonStyleDefault;
    }
    
    return self;
}

- (void)setStyle:(CKButtonStyle)aStyle
{
    style = aStyle;
    
    if (CKButtonStyleTextComment == style) {
        [self stylizeButtonForTextComment];
    }
    else if (CKButtonStyleMediaComment == style) {
        [self stylizeButtonForMediaComment];
    }
    else if (CKButtonStyleVideoOverlay == style) {
        [self stylizeButtonForVideoOverlay];
    }
    else if (CKButtonStyleLogin == style) {
        [self stylizeButtonForLogin];
    }
    else {
        [self stylizeButtonForDefault];
    }
}

- (void)stylizeButtonForDefault
{
    [self setBackgroundImage:[UIImage canvasKit1ImageNamed:@"button"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage canvasKit1ImageNamed:@"button_pressed"] forState:UIControlStateSelected];
    self.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)stylizeButtonForTextComment
{
    [self setBackgroundImage:[UIImage canvasKit1ImageNamed: @"button-textcomment"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage canvasKit1ImageNamed:@"button_pressed"] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    self.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)stylizeButtonForMediaComment
{
    [self setBackgroundImage:[UIImage canvasKit1ImageNamed: @"button-mediacomment"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage canvasKit1ImageNamed:@"button_pressed"] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    self.layer.borderColor = [[UIColor darkTextColor] CGColor];
}

- (void)stylizeButtonForVideoOverlay
{
    [self setBackgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.7]];
    [self setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    [self setAlpha:0.5];
}

- (void)stylizeButtonForLogin
{
    UIImage *backgroundImage = [UIImage canvasKit1ImageNamed:@"button-get-started"];
    backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    UIImage *backgroundImagePressed = [UIImage canvasKit1ImageNamed:@"button-get-started-pressed"];
    backgroundImagePressed = [backgroundImagePressed resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    [self setBackgroundImage:backgroundImagePressed forState:UIControlStateHighlighted];
    
    [self setBackgroundColor:[UIColor colorWithRed:255 green:255 blue:255 alpha:0.7]];
    [self setTitleColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.7] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    self.layer.borderWidth = 0.0f;
    
//    self.layer.borderColor = [[UIColor blueColor] CGColor];
    //[self setAlpha:0.5];
}

@end
