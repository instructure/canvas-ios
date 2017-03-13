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
