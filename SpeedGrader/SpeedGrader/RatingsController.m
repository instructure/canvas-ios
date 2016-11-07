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

#import "RatingsController.h"
#import "ModalPresenter.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "EasyAlertView.h"

@import CanvasKeymaster;

// debugging launch arguments
// If this string is included as a launch argument, the ratings dialog will appear every time the app is launched,
// not just if the conditions are met
static NSString *alwaysShowArgument = @"alwaysShowRatingAlert";
// Reset defaults for the keys applicable to RatingsController
static NSString *resetRatingsController = @"resetRatingsController";

// user defaults keys
static NSString *appLoadedCountKey = @"appLoadedCountKey";
static NSString *appRatingShownKey = @"appRatingShownKey";

// functionality Constants
static NSInteger showAfterNLoads = 5;

// Ratings Alert Constants
static NSString *promptText = @"How do you like Speedgrader?";
static NSString *loveItText = @"Love it!";
static NSString *problemsText = @"It has problems";
static NSString *notRightNowText = @"Ask me later";
static NSString *optOutText = @"Don't ask me again";

// Ratings Prompt Constants
static NSString *rateTitle = @"Rate on App Store";
static NSString *rateMessage = @"Would you mind giving us a rating on the app store?";

// Feedback Prompt Constants
static NSString *feedbackTitle = @"Tell us what's wrong";
static NSString *feedbackMessage = @"Would you mind letting us know the problems you have been having with the app?";

// Prompt button Constants
static NSString *sureTitle = @"Sure!";
static NSString *noTitle = @"No Thanks";

// AlertView presentation view
static inline UIView* presentationViewForAlerts(){return [[[UIApplication sharedApplication] delegate] window];}

static RatingsController *_ratingsController;

@interface RatingsController ()

@property (nonatomic, retain) EasyAlertView *alertView;
@property (nonatomic, retain) UIViewController *presentingController;

@end

@implementation RatingsController

#pragma mark - View Life Cycle

+(void)load{
    [super load];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{appLoadedCountKey : @0,
                                 appRatingShownKey : @NO}];
}

#pragma mark - Button Targets

/** Ask the user if he wants to rate us on the app store*/
-(void)promptForRating{
    void (^sureBlock)() = ^void(){
        [self gotoAppStore];
    };
    
    [EasyAlertView presentAlertFromView:presentationViewForAlerts()
                              withTitle:rateTitle
                                message:rateMessage
                           buttonTitles:@[sureTitle, noTitle]
                           buttonBlocks:@[sureBlock, [EasyAlertView doNothingBlock]]];
}

/** Ask the user if he wants to provide us email feedback*/
-(void)promptForFeedback{
    void (^sureBlock)() = ^void(){
        [self submitFeedback];
    };
    
    [EasyAlertView presentAlertFromView:presentationViewForAlerts()
                              withTitle:feedbackTitle
                                message:feedbackMessage
                           buttonTitles:@[sureTitle, noTitle]
                           buttonBlocks:@[sureBlock, [EasyAlertView doNothingBlock]]];
}

/** Open up our own app in the app store*/
-(void)gotoAppStore{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms://itunes.apple.com/us/app/canvas-by-instructure/id418441195?mt=8"]];
}

/** Submit feedback through email*/
-(void)submitFeedback{
    //PUSH Help
    UINavigationController *navController = [[UIStoryboard storyboardWithName:@"SupportTicket-iPad" bundle:nil] instantiateInitialViewController];
    SupportTicketViewController *controller = navController.viewControllers[0];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    controller.ticketType = SupportTicketTypeProblem;
    [self.presentingController presentViewController:navController animated:YES completion:nil];
}

#pragma mark - Static Presentation Methods and User Defaults handling

+(NSUInteger)appLoadedOnViewController:(UIViewController*) presentingViewController{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    ////////////////
    // FOR DEBUGGING
    if ([[[NSProcessInfo processInfo] arguments] containsObject:resetRatingsController]) {
        [defaults setObject:@0 forKey:appLoadedCountKey];
        [defaults setObject:@NO forKey:appRatingShownKey];
    }

    ///////////////////////
    // LOAD DEFAULTS VALUES
    NSNumber *appLoadedCount = [defaults objectForKey:appLoadedCountKey];
    appLoadedCount = @([appLoadedCount integerValue] + 1);
    [defaults setObject:appLoadedCount forKey:appLoadedCountKey];
    NSNumber *shown = [defaults objectForKey:appRatingShownKey];
    
    ////////////////
    // DISPLAY LOGIC
    if ([[[NSProcessInfo processInfo] arguments] containsObject:alwaysShowArgument]){
        // this is a debugging mode, user should never come in here
        [RatingsController promptForRatingOnViewController:presentingViewController];
    }else if ([appLoadedCount integerValue] >= showAfterNLoads && ![shown boolValue]){
        [RatingsController promptForRatingOnViewController:presentingViewController];
    }
    
    return [appLoadedCount unsignedIntegerValue];
}

/** Setup and present the ratings dialog. 
 
 @see appLoadedOnViewController for instructions on how we use presentingViewController*/
+(void)promptForRatingOnViewController:(UIViewController*) presentingViewController{
    /////////////////
    // WRITE DEFAULTS
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@YES forKey:appRatingShownKey];
    
    ////////////////////
    // RATING CONTROLLER
    _ratingsController = [[RatingsController alloc] init];
    _ratingsController.presentingController = presentingViewController;
    
    ////////////
    // ALERTVIEW
    NSArray *buttonTitles = @[loveItText, problemsText, optOutText, notRightNowText];
    void (^loveBlock)() = ^void(){
        [_ratingsController promptForRating];
    };
    void (^problemsBlock)() = ^void(){
        [_ratingsController promptForFeedback];
    };
    void (^optOutBlock)() = [EasyAlertView doNothingBlock]; // if they press "optOut", then shown will remain at @YES, and we will never show again
    void (^notRightNowBlock)() = ^void(){
        // if they don't want us to bother them right now, start the number of loads count
        // over, and turn of "shown"
        [defaults setObject:@0 forKey:appLoadedCountKey];
        [defaults setObject:@NO forKey:appRatingShownKey];
    };
    NSArray *buttonBlocks = @[loveBlock, problemsBlock, optOutBlock, notRightNowBlock];
    
    _ratingsController.alertView = [EasyAlertView presentAlertFromView:[[[UIApplication sharedApplication] delegate] window] withTitle:promptText message:nil buttonTitles:buttonTitles buttonBlocks:buttonBlocks];
}



@end
