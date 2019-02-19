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
    
    

#import "CNVTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+TechDebt.h"

@interface CNVTableViewCell ()
- (void)setupBackground;
@end

@implementation CNVTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupBackground];
    }
    return self;
}

- (void)setupBackground {
    
    UIImage *cellBackgroundImage = [UIImage techDebtImageNamed:@"tableviewcell-background"];
    cellBackgroundImage = [cellBackgroundImage resizableImageWithCapInsets:
                           UIEdgeInsetsMake(0,
                                            0,
                                            cellBackgroundImage.size.height - 1,
                                            0)];
    UIImageView *gradientBackgroundView = [[UIImageView alloc] initWithImage:cellBackgroundImage];
    gradientBackgroundView.contentMode = UIViewContentModeScaleToFill;
    gradientBackgroundView.frame = self.bounds;
    gradientBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.backgroundView = gradientBackgroundView;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupBackground];

}

@end
