//
//  CKMViewController.m
//  CanvasKeytester
//
//  Created by Derrick Hathaway on 4/24/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKMViewController.h"
#import "CanvasKeymaster.h"

@interface CKMViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@end

@implementation CKMViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.userLabel.text = TheKeymaster.currentClient.currentUser.name;
}

- (IBAction)logout:(id)sender {
    [TheKeymaster logout];
}

- (IBAction)switchUser:(id)sender {
    [TheKeymaster switchUser];
}

@end
