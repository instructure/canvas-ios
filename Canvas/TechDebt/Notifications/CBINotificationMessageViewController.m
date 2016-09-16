//
// Created by Jason Larsen on 1/17/14.
// Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CBINotificationMessageViewController.h"
@import CanvasKit;

@interface CBINotificationMessageViewController ()
@property (nonatomic, weak) IBOutlet UILabel *messageLabel;
@end

@implementation CBINotificationMessageViewController

- (instancetype)init
{
    return self = [[UIStoryboard storyboardWithName:@"CBINotificationMessage" bundle:[NSBundle bundleForClass:[self class]]] instantiateInitialViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupViewConstraints];

    RAC(self, messageLabel.text) = [RACObserve(self, streamItem.message) map:^id(NSString *message) {
        return [[[NSAttributedString alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil] string];
    }];
}

- (void)setupViewConstraints
{
    UIView *spacerView = [[UIView alloc] init];
    spacerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
    spacerView.hidden = YES;
    [self.view insertSubview:spacerView belowSubview:self.messageLabel];
    UILabel *messageLabel = self.messageLabel;
    NSDictionary *views = NSDictionaryOfVariableBindings(spacerView, messageLabel);
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:spacerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeHeight multiplier:0.33f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:spacerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:spacerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:spacerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.messageLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:spacerView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-[messageLabel]-|" options:0 metrics:nil views:views]];
}

@end