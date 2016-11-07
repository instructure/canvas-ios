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
    
    

#import <CanvasKit1/CKRemoteImageView.h>

#import "IconCell.h"
#import "NSCache+AvatarCache.h"
#import "UIImage+TechDebt.h"


@interface IconCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingSpaceContstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingSpaceConstraint;
@end

@implementation IconCell {
    BOOL _sequentialChecked, _sequentialUnchecked;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.dateLabel.text = @"";
    self.titleLabel.text = @"";
    self.subtitleLabel.text = @"";
    self.whiteImageView.imageCache = [NSCache sharedAvatarCache];
    self.orangeImageView.imageCache = [NSCache sharedAvatarCache];
}

- (void)setImageViewWidth:(CGFloat)imageViewWidth
{
    self.imageViewWidthConstraint.constant = imageViewWidth;
}

- (CGFloat)imageViewWidth
{
    return self.imageViewWidthConstraint.constant;
}

- (void)setCellPadding:(CGFloat)cellPadding
{
    _cellPadding = cellPadding;
    self.trailingSpaceContstraint.constant = -cellPadding;
    self.leadingSpaceConstraint.constant = cellPadding;
}

- (void)updateImageHighlights
{
    BOOL highlighted = self.selected || self.highlighted;
    
    // module item status
    UIImageView *accessoryImageView;
    if (self.sequentialChecked) {
        accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage techDebtImageNamed:@"icon_checked_fill"]];
    } else if (self.sequentialUnchecked) {
        accessoryImageView = [[UIImageView alloc] initWithImage:[UIImage techDebtImageNamed:@"icon_unchecked_fill"]];
    }
    if (highlighted) {
        accessoryImageView.tintColor = [UIColor whiteColor];
    } else {
        accessoryImageView.tintColor = [UIColor blackColor];
    }
    self.accessoryView = accessoryImageView;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self updateImageHighlights];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (animated) {
        [UIView animateWithDuration:0.3333 animations:^{
            [self updateImageHighlights];
        }];
    } else {
        [self updateImageHighlights];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [self updateImageHighlights];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    if (animated) {
        [UIView animateWithDuration:0.3333 animations:^{
            [self updateImageHighlights];
        }];
    } else {
        [self updateImageHighlights];
    }
}

@end

#pragma mark - ModuleItemCell behavior

@implementation IconCell (ModuleItemCell)

- (void)setSequentialChecked:(BOOL)sequentialChecked {
    _sequentialChecked = sequentialChecked;
    [self updateImageHighlights];
}
- (BOOL)sequentialChecked {
    return _sequentialChecked;
}

- (void)setSequentialUnchecked:(BOOL)sequentialUnchecked
{
    _sequentialUnchecked = sequentialUnchecked;
    [self updateImageHighlights];
}
- (BOOL)sequentialUnchecked {
    return _sequentialUnchecked;
}

@end


#pragma mark - UITableView+IconCell

@implementation UITableView (IconCell)

- (void)registerIconCellForReuse {
    [self registerNib:[UINib nibWithNibName:@"IconCell" bundle:[NSBundle bundleForClass:[self class]]] forCellReuseIdentifier:@"IconCell"];
}
- (IconCell *)dequeueReusableIconCellForIndexPath:(NSIndexPath *)indexPath
{
    return [self dequeueReusableCellWithIdentifier:@"IconCell" forIndexPath:indexPath];
}


@end