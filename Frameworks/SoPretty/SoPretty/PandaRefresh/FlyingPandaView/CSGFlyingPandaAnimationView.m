
//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
    
    

#import "CSGFlyingPandaAnimationView.h"

@interface CSGFlyingPandaAnimationView ()

@property (nonatomic, assign) BOOL isAnimating;
@property (nonatomic, assign) NSInteger maxOnscreenClouds;
@property (nonatomic, strong) CADisplayLink *cloudDisplayLink;
@property (nonatomic, assign) CFTimeInterval currentFrameTimestamp;
@property (nonatomic, assign) CFTimeInterval nextCloudTimestamp;
@property (nonatomic, strong) NSArray *cloudImages;

@end

UIImage *imageNamed(NSString *name){
    NSBundle *frameworkBundle = [NSBundle bundleForClass:[CSGFlyingPandaAnimationView class]];
    return [UIImage imageNamed:name inBundle:frameworkBundle compatibleWithTraitCollection:nil];
}

@implementation CSGFlyingPandaAnimationView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initializeAnimationView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeAnimationView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeAnimationView];
    }
    return self;
}

- (void)initializeAnimationView
{
    _flyingPandaImageView = [[UIImageView alloc] init];
    _flyingPandaImageView.animationImages = @[imageNamed(@"panda_1"), imageNamed(@"panda_2"), imageNamed(@"panda_3"), imageNamed(@"panda_4"), imageNamed(@"panda_5")];
    _flyingPandaImageView.animationDuration = kFlyingPandaAnimationImageCount / 14.0;
    _flyingPandaImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:_flyingPandaImageView];

    _cloudImages = @[imageNamed(@"cloud_1"), imageNamed(@"cloud_2"), imageNamed(@"cloud_3"), imageNamed(@"cloud_4"), imageNamed(@"cloud_5")];

    _onscreenClouds = [NSMutableArray array];

    srand48(time(0));
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat cloudToSkyRatio = 0.33f;// 1/3rd of the screen should be filled, potentially overlapping though, of clouds
    CGFloat skyArea = self.bounds.size.width * self.bounds.size.height;
    CGFloat avgCloudArea = 80.0f * 60.0f; // the average size of a cloud;
    self.maxOnscreenClouds = skyArea / avgCloudArea * cloudToSkyRatio;
}

- (void)startAnimating
{
    [self.flyingPandaImageView startAnimating];
    self.cloudDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateClouds)];
    [self.cloudDisplayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];

    self.isAnimating = YES;
}

- (void)stopAnimating
{
    [self.flyingPandaImageView.layer removeAllAnimations];
    [self.cloudDisplayLink invalidate];
    self.cloudDisplayLink = nil;
    for (UIImageView *onscreenCloud in self.onscreenClouds) {
        [onscreenCloud removeFromSuperview];
    }
    [self.onscreenClouds removeAllObjects];

    self.isAnimating = NO;
}


#pragma mark - Private methods

- (void)updateClouds
{
    CFTimeInterval currentTime = self.cloudDisplayLink.timestamp;
    self.currentFrameTimestamp = currentTime;

    if (self.onscreenClouds.count == 0) {
        self.nextCloudTimestamp = self.currentFrameTimestamp;
    }

    if (self.currentFrameTimestamp >= self.nextCloudTimestamp && self.isAnimating) {
        UIImage *cloudImage = [self randomCloudImage];
        UIImageView *cloudImageView = [[UIImageView alloc] initWithImage:cloudImage];
        cloudImageView.frame = CGRectMake(self.bounds.size.width, [self randomCloudYValueForImage:cloudImage viewHeight:self.bounds.size.height], cloudImage.size.width, cloudImage.size.height);
        [self insertSubview:cloudImageView belowSubview:self.flyingPandaImageView];
        [self.onscreenClouds addObject:cloudImageView];

        [UIView animateWithDuration:[self randomCloudTravelTime] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            CGRect destinationRect = cloudImageView.frame;
            destinationRect.origin.x = 0 - cloudImage.size.width;
            cloudImageView.frame = destinationRect;
        } completion:^(BOOL finished) {
            [self.onscreenClouds removeObject:cloudImageView];
            [cloudImageView removeFromSuperview];
        }];

        self.nextCloudTimestamp = [self nextCloudAppearanceTime];
    }
}

- (UIImage *)randomCloudImage
{
    NSInteger random = arc4random_uniform(kCloudAnimationImageCount);
    UIImage *cloudImage = self.cloudImages[random];
    return cloudImage;
}

- (CGFloat)randomCloudYValueForImage:(UIImage *)cloudImage viewHeight:(CGFloat)viewHeight
{
    CGFloat randomY = arc4random_uniform(viewHeight - cloudImage.size.height);
    return randomY;
}

- (CFTimeInterval)nextCloudAppearanceTime
{
    double random = drand48() * 2; // 0-2 seconds spacing
    CFTimeInterval nextAppearance = self.currentFrameTimestamp + random;
    return nextAppearance;
}

- (NSTimeInterval)randomCloudTravelTime
{
    NSInteger ptsPerSec = arc4random_uniform(40) + 120; // 120-159 is the range for pts per second
    double time = self.bounds.size.width / ptsPerSec;
    return time;
}

@end
