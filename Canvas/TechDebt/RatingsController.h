//
//  RatingsController.h
//  iCanvas
//
//  Created by Nathan Perry on 3/31/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RatingsController : NSObject

/** Tell the RatingsController that the app has loaded once. If the app has loaded
 more than a certain number of times, it will present the ratings dialog.
 
 @parem presentingViewController if the user chooses to send feedback, we will present
 an MFMailComposeViewController email prompt. Email prompts must be presented from
 a view controller. We will use the given view controller to present. If nil is given,
 the email dialog will simply not be shown.
 @return How many times has either method in this class been called in the history of 
 this app on this particular device.*/
+(NSUInteger)appLoadedOnViewController:(UIViewController*) presentingViewController;



/** Tell the RatingsController that the app has loaded once. If the app has loaded
 more than a certain number of times, it will present the ratings dialog.
 
 @parem presentingViewController if the user chooses to send feedback, we will present
 an MFMailComposeViewController email prompt. Email prompts must be presented from
 a view controller. We will use the given view controller to present. If nil is given,
 the email dialog will simply not be shown.
 @return How many times has this method been called in the history of this app on this
 
 @parem prompt this required param is used to show the user a custom prompt message
 for rating the app. IE) How did you like <quizzes/calendar/discussion>? This method
 was created to help promote new features but is aplicable to most parts of the app.
 
 @return How many times has either method in this class been called in the history of 
  this app on this particular device.*/
+(NSUInteger)appLoadedOnViewController:(UIViewController*) presentingViewController WithPrompt:(NSString*) prompt;
@end
