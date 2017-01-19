//
//  CKMDomainHelpViewController.m
//  CanvasKeymaster
//
//  Created by Brandon Pluim on 8/13/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
//

#import "CKMDomainHelpViewController.h"

static NSString *const CKMDomainHelpURL = @"https://community.canvaslms.com/docs/DOC-1543";

@interface CKMDomainHelpViewController ()

@end

@implementation CKMDomainHelpViewController

+ (instancetype)instantiateFromStoryboard
{
    CKMDomainHelpViewController *instance = [[UIStoryboard storyboardWithName:NSStringFromClass(self) bundle:[NSBundle bundleForClass:self]] instantiateInitialViewController];
    NSAssert([instance isKindOfClass:[CKMDomainHelpViewController class]], @"View controller from storyboard is not an instance of %@", NSStringFromClass(self));
    
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancelButtonPressed:)];
    self.title = NSLocalizedString(@"Help", @"Help View Controller Title");

    [self.cancelButton setAccessibilityLabel:NSLocalizedString(@"Cancel", nil)];
    [self.cancelButton setAccessibilityIdentifier:@"cancelHelpButton"];
    
    self.webview.scalesPageToFit = YES;
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:CKMDomainHelpURL]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonPressed:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
