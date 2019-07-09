//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "MobileQuizInformationViewController.h"

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

    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSString *warningInfo = NSLocalizedStringFromTableInBundle(@"Canvas quizzes support various assessment styles. Most of these styles are supported on mobile devices; however, some are not. If you attempt to take one of these unsupported quizzes on your phone, you might be unable to complete the entire quiz, leaving you at a disadvantage.\n\nUnsupported question types include questions containing Adobe Flash™ content, and others.\n\nIf you believe that a quiz contains unsupported content, please take it on desktop or laptop computer. If you know that the quiz contains only supported content, feel free to take it on your mobile device.", nil, bundle, @"mobile quiz warning info");
    
    self.textView.text = warningInfo;
    self.title = NSLocalizedStringFromTableInBundle(@"Mobile Quiz Warning", nil, bundle, @"Warnging for taking quizzes on a mobile device");

}

- (IBAction)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
