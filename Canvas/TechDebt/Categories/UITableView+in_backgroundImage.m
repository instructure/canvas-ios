//
//  UITableView+in_backgroundImage.m
//  iCanvas
//
//  Created by BJ Homer on 11/7/12.
//  Copyright (c) 2012 Instructure. All rights reserved.
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
