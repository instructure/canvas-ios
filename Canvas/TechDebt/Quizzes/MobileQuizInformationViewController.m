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
    
    

#import "MobileQuizInformationViewController.h"
#import "CBILog.h"

@interface MobileQuizInformationViewController ()
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation MobileQuizInformationViewController


+ (void)presentFromViewController:(UIViewController *)viewController;
{
    [viewController presentViewController:[UIStoryboard storyboardWithName:@"MobileQuizInformation" bundle:[NSBundle bundleForClass:[MobileQuizInformationViewController class]]].instantiateInitialViewController animated:YES completion:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.textView.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
    
    NSString *warningInfo = NSLocalizedString(@"Canvas quizzes support various assessment styles. Most of these styles are supported on mobile devices; however, some are not. If you attempt to take one of these unsupported quizzes on your phone, you might be unable to complete the entire quiz, leaving you at a disadvantage.\n\nUnsupported question types include questions containing Adobe Flash™ content, and others.\n\nIf you believe that a quiz contains unsupported content, please take it on desktop or laptop computer. If you know that the quiz contains only supported content, feel free to take it on your mobile device.", @"mobile quze warning info");
    
    self.textView.text = warningInfo;
    self.title = NSLocalizedString(@"Mobile Quiz Warning", @"Warnging for taking quizzes on a mobile device");

}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    DDLogVerbose(@"%@ - viewDidAppear", NSStringFromClass([self class]));
}

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    DDLogVerbose(@"doneButtonTapped");
}

@end
