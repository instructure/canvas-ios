
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
