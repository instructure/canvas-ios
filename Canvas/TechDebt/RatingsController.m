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

@import Secrets;
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
static NSInteger showAfterNLoads = 3;

// email constants
static NSString *emailAddress = @"mobilesupport@instructure.com";
static NSString *emailSubject = @"Canvas-iOS Feedback";

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
                              withTitle:NSLocalizedString(@"Rate on App Store",nil)
                                message:NSLocalizedString(@"Would you mind giving us a rating on the app store?",nil)
                           buttonTitles:@[NSLocalizedString(@"Sure!",nil), NSLocalizedString(@"No Thanks",nil)]
                           buttonBlocks:@[sureBlock, [EasyAlertView doNothingBlock]]];
}

/** Ask the user if he wants to provide us email feedback*/
-(void)promptForFeedback{
    void (^sureBlock)() = ^void(){
        [self submitFeedback];
    };
    
    [EasyAlertView presentAlertFromView:presentationViewForAlerts()
                              withTitle:NSLocalizedString(@"Tell us what's wrong",nil)
                                message:NSLocalizedString(@"Would you mind letting us know the problems you have been having with the app?",nil)
                           buttonTitles:@[NSLocalizedString(@"Sure!",nil), NSLocalizedString(@"No Thanks",nil)]
                           buttonBlocks:@[sureBlock, [EasyAlertView doNothingBlock]]];
}

/** Open up our own app in the app store*/
-(void)gotoAppStore{
    NSString *stringURL = [Secrets fetch:SecretKeyCanvasAppStore];
    if (stringURL) {
        NSURL *url = [NSURL URLWithString:stringURL];
        [[UIApplication sharedApplication] openURL:url];
    }
}

-(void)submitFeedback{
    self.alertView.view.hidden = YES;
    
    [SupportTicketViewController presentFromViewController: self.presentingController supportTicketType: SupportTicketTypeProblem];
}

#pragma mark - Static Presentation Methods and User Defaults handling

+(NSUInteger)appLoadedOnViewController:(UIViewController*) presentingViewController{
    return [self appLoadedOnViewController:presentingViewController WithPrompt:NSLocalizedString(@"How do you like Canvas?",nil)];
}
+(NSUInteger)appLoadedOnViewController:(UIViewController*) presentingViewController WithPrompt:(NSString*)prompt{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    //we only want to add one count for each session
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
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
            [RatingsController promptForRatingOnViewController:presentingViewController WithPrompt:prompt];
        }else if ([appLoadedCount integerValue] >= showAfterNLoads && ![shown boolValue]){
            [RatingsController promptForRatingOnViewController:presentingViewController WithPrompt:prompt];
        }
    });
    
    return [[defaults objectForKey:appLoadedCountKey] unsignedIntegerValue];
}

/** Setup and present the ratings dialog.
 
 @see appLoadedOnViewController for instructions on how we use presentingViewController*/
+(void)promptForRatingOnViewController:(UIViewController*) presentingViewController WithPrompt:(NSString *)prompt{
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
    NSArray *buttonTitles = @[NSLocalizedString(@"Love it!",nil), NSLocalizedString(@"It has problems",nil), NSLocalizedString(@"Don't ask me again",nil), NSLocalizedString(@"Ask me later",nil)];
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
    
    _ratingsController.alertView = [EasyAlertView presentAlertFromView:[[[UIApplication sharedApplication] delegate] window] withTitle:prompt message:nil buttonTitles:buttonTitles buttonBlocks:buttonBlocks];
}

@end
