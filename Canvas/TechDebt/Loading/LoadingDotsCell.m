//
//  LoadingDotsCell.m
//  iCanvas
//
//  Created by BJ Homer on 5/1/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "LoadingDotsCell.h"
#import "UITableView+in_backgroundImage.h"
#import <CanvasKit1/CKCrossfadingImageView.h>
#import "UIImage+TechDebt.h"

@implementation LoadingDotsCell {
    CKCrossfadingImageView *loader;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setIcBackgroundImage:nil];
        [self setIcBackgroundHighlightedImage:nil];
        loader = [[CKCrossfadingImageView alloc] initWithFrame:self.bounds];
        loader.contentMode = UIViewContentModeCenter;
        
        loader.animationImages = (@[ [UIImage techDebtImageNamed:@"loadingmore1"],
                                  [UIImage techDebtImageNamed:@"loadingmore2"],
                                  [UIImage techDebtImageNamed:@"loadingmore3"]
                                  ]);
        loader.animationDuration = 1.5;
        loader.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
        [self.contentView addSubview:loader];
    }
    return self;
}

- (void)setDarkLoadingDotColor {
    loader.animationImages = (@[
                               [UIImage techDebtImageNamed:@"loadingmore1_gray"],
                               [UIImage techDebtImageNamed:@"loadingmore2_gray"],
                               [UIImage techDebtImageNamed:@"loadingmore3_gray"]
                               ]);
}

- (void)didMoveToWindow {
    if (self.window) {
        [loader startAnimating];
    }
    else {
        [loader stopAnimating];
    }
}

- (CGSize)intrinsicContentSize {
    return (CGSize) {
        .height = 30,
        .width = 50,
    };
}

@end
