//
//  CKRemoteImageButton.m
//  CanvasKit
//
//  Created by Jason Larsen on 8/21/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
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
