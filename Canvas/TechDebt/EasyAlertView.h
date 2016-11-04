
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

/** 
 A take on AlertView that is indpendent of UIAlertView and AlertViewController. Thus it works in iOS 7 but won't be deprecated in iOS 8.
 
 @see +presentAlertFromView:withTitle:message:buttonTitles:buttonBlocks:
 */
@interface EasyAlertView : UIViewController

/**Create and present an EasyAlertView. Follows a lot of the UIAlertView conventions, but is not iOS version dependent, i.e. won't get deprecated in iOS 8.
 
 @parem presentingView The EasyAlertView is not required to be fullScreen. You can present in on any view. If you want it full screen, like a traditional alert view,
 use [[[UIApplication sharedApplication] delegate] window]
 
 @parem title Same as UIAlertView title
 @parem message Same as UIAlertView message
 @parem titles An array of strings. Each string will be the title for a button. Buttons are presented in the order given by the array.
 @parem blocks An array of blocks. Must have the same cardinality as titles. Also button targets are simply set by ordering. Dismissing
 is done automatically by the EasyAlertView. You shouldn't try to dismiss the AlertView in the block. Blocks should have no parameters
 and no return type, i.e. void (^blockName)() = ^void(){<#code#>};
 
 @return The created EasyAlertView
 */
+(EasyAlertView*)presentAlertFromView:(UIView*)presentingView withTitle:(NSString*) title message:(NSString*) message buttonTitles:(NSArray*) titles buttonBlocks:(NSArray*) blocks;
/** Convenience method, if you want a button to do nothing but dismiss the alert, put in a block that does nothing in the corresponding blockArray*/
+(void(^)()) doNothingBlock;

@end
