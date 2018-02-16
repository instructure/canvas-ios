//
//  CKILoginFinishedViewController.m
//  CanvasKit
//
//  Created by Layne Moseley on 2/15/18.
//  Copyright © 2018 Instructure. All rights reserved.
//

#import "CKILoginFinishedViewController.h"

@interface CKILoginFinishedViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *loadingImageView;
@property (nonatomic, weak) UIImage *image;

@end

@implementation CKILoginFinishedViewController

- (id)init {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    return [[UIStoryboard storyboardWithName:@"LoginFinished" bundle:bundle] instantiateInitialViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.loadingImageView.image = self.image;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(0);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = 100.0;
    animation.duration = 10.0;
    [self.loadingImageView.layer addAnimation:animation forKey:@"spinnnnnnn"];
}

- (void)setLoadingImage:(UIImage *)image {
    self.image = image;
}

@end
