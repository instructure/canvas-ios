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
