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
    
    

#import "CKRemoteImageButton.h"
#import "CKRemoteImageView.h"

@interface CKRemoteImageButton ()
@property (nonatomic, strong) UIView *pressedLayer;
@end

@implementation CKRemoteImageButton

static void commonSetup(CKRemoteImageButton *self) {
    [self addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
    self.remoteImageView = [[CKRemoteImageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.remoteImageView];
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
    
    self.pressedLayer = [[UIView alloc] initWithFrame:self.bounds];
    self.pressedLayer.backgroundColor = [UIColor blackColor];
    self.pressedLayer.alpha = 0;
    [self addSubview:self.pressedLayer];
}

+ (id)buttonWithType:(UIButtonType)buttonType
{
    CKRemoteImageButton *button = [super buttonWithType:buttonType];
    commonSetup(button);
    return button;
}

- (void)setContentMode:(UIViewContentMode)contentMode
{
    [super setContentMode:contentMode];
    self.remoteImageView.contentMode = contentMode;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    commonSetup(self);
}

- (void)setImageCache:(NSCache *)imageCache
{
    self.remoteImageView.imageCache = _imageCache = imageCache;
}

- (void)setImageURL:(NSURL *)imageURL
{
    self.remoteImageView.imageURL = _imageURL = imageURL;
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state {
    [super setImage:image forState:state];
    self.remoteImageView.image = image;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.remoteImageView.frame = self.bounds;
    self.pressedLayer.frame = self.bounds;
}

- (void)tapped
{
    if (self.tapBlock) {
        self.tapBlock();
    }    
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {        
        self.pressedLayer.alpha = .4;
    }
    else {
        self.pressedLayer.alpha = 0;
    }
}

@end
