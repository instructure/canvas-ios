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

#import "CKMDomainSearchViewController.h"
#import "CKMDomainSuggestionTableViewController.h"
#import "CKMLocationSchoolSuggester.h"
#import "CanvasKeymaster.h"

@import ReactiveObjC;
@import CanvasKit;

@interface CKMDomainSearchViewController () <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;
@property (nonatomic, weak) IBOutlet UITextField *searchTextField;
@property (nonatomic, weak) IBOutlet UIView *suggestionContainer;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) CKMDomainSuggestionTableViewController *suggestionTableViewController;
@property (nonatomic) BOOL poppedKeyboardOnFirstAppear;

@end

@implementation CKMDomainSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.logoImageView.image = TheKeymaster.delegate.logoForDomainPicker;
    [self.closeButton setImage:[[UIImage imageNamed:@"x-icon" inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    
    @weakify(self);
    [self.suggestionTableViewController.selectedSchoolSignal subscribeNext:^(CKIAccountDomain *school) {
        @strongify(self);
        [self.delegate sendDomain:school];
    }];
    
    [self.suggestionTableViewController.selectedHelpSignal subscribeNext:^(id x) {
        @strongify(self);
        [self.delegate showHelpPopover];
    }];
    
    [self.searchTextField addTarget:self action:@selector(textFieldWasEdited:) forControlEvents:UIControlEventAllEditingEvents];
    
    CKMLocationSchoolSuggester *suggestor = [CKMLocationSchoolSuggester shared];
    RACSignal *fetching = RACObserve(suggestor, fetching);
    RACSignal *text = self.searchTextField.rac_textSignal;
    RAC(self.spinner, animating) = [[[fetching combineLatestWith:text] map:^id (RACTuple* value) {
        NSNumber *fetching = value.first;
        NSString *text = value.second;
        return @([fetching boolValue] && text.length > 0);
    }] deliverOnMainThread];
    
    self.poppedKeyboardOnFirstAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.poppedKeyboardOnFirstAppear) {
        self.poppedKeyboardOnFirstAppear = YES;
        [self.searchTextField becomeFirstResponder];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedSuggestions"]) {
        self.suggestionTableViewController = segue.destinationViewController;
    }
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldWasEdited:(id)sender {
    self.suggestionTableViewController.query = self.searchTextField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    CKIAccountDomain *domain = [[CKIAccountDomain alloc] initWithDomain:self.searchTextField.text];
    [self.delegate sendDomain:domain];
    return YES;
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return NO;
    }
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    
    return UIInterfaceOrientationMaskAll;
}

@end
