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
