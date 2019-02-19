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
    
    

#import "UITableView+in_backgroundImage.h"

@implementation UITableViewCell (in_backgroundImage)

- (UIImage *)icBackgroundImage {
    if ([self.backgroundView isKindOfClass:[UIImageView class]]) {
        return [(UIImageView *)self.backgroundView image];
    }
    else {
        return nil;
    }
}

- (void)setIcBackgroundImage:(UIImage *)image {
    if ([self.backgroundView isKindOfClass:[UIImageView class]]) {
        [(UIImageView *)self.backgroundView setImage:image];
    }
    else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.frame = self.bounds;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundView = imageView;
    }
}

- (UIImage *)icBackgroundHighlightedImage {
    if ([self.backgroundView isKindOfClass:[UIImageView class]]) {
        return [(UIImageView *)self.backgroundView image];
    }
    else {
        return nil;
    }
}

- (void)setIcBackgroundHighlightedImage:(UIImage *)image {
    if ([self.backgroundView isKindOfClass:[UIImageView class]]) {
        [(UIImageView *)self.backgroundView setHighlightedImage:image];
    }
    else {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
        imageView.highlightedImage = image;
        imageView.contentMode = UIViewContentModeScaleToFill;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundView = imageView;
    }
}


@end


@implementation UITableView (in_backgroundImage)

- (UIImage *)icBackgroundImage {
    if ([self.backgroundView isKindOfClass:[UIImageView class]]) {
        return [(UIImageView *)self.backgroundView image];
    }
    else {
        return nil;
    }
}

- (void)setIcBackgroundImage:(UIImage *)image {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    self.backgroundView = imageView;
}

@end


@implementation UILabel (ic_textColor)

- (UIColor *)icTextColor {
    return self.textColor;
}

- (void)setIcTextColor:(UIColor *)icTextColor {
    if (icTextColor == nil) {
        return;
    }
    self.textColor = icTextColor;
}

@end
