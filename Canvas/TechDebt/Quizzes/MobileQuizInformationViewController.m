//
//  MobileQuizInformationViewController.m
//  iCanvas
//
//  Created by rroberts on 11/15/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
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
    
    NSString *warningInfo = NSLocalizedString(@"Canvas quizzes support various assessment styles. Most of these styles are supported on mobile devices; however, some are not. If you attempt to take one of these unsupported quizzes on your phone, you might be unable to complete the entire quiz, leaving you at a disadvantage.\n\nUnsupported question types include questions containing Adobe Flash™ content, file uploads, and others.\n\nIf you believe that a quiz contains unsupported content, please take it on desktop or laptop computer. If you know that the quiz contains only supported content, feel free to take it on your mobile device.", @"mobile quze warning info");
    
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
