
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
    
    

#import "NonResponsiveTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation NonResponsiveTextField {
    UIImageView *imageView;
}

- (BOOL)isAccessibilityElement {
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return NO;
}


- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow != nil) {
        UITextField *textField = [[UITextField alloc] initWithFrame:self.bounds];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
        [textField.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [imageView removeFromSuperview];
        
        imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        
        image = [image resizableImageWithCapInsets:(UIEdgeInsets) {
            .top = 8,
            .right = 8,
            .bottom = 8,
            .left = 8
        }];
        imageView.image = image;
        [self insertSubview:imageView atIndex:0];
        self.backgroundColor = [UIColor clearColor];
    }
    [super willMoveToWindow:newWindow];
}

@end
