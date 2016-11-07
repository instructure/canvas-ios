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

#import <Foundation/Foundation.h>

/** Intended to be a protocol on UIViewController. Thus do not add any more methods to it,
 because we want any UIViewController to theoretically be presentable*/
@protocol ModalPresentable <NSObject>
-(UIView*) view;
@end

/** Singleton class, which can be used to present an view modally*/
@interface ModalPresenter : UIViewController

/** Present a ModalPresentable as a modal over the given view. Only supports one modal at a time,
 thus if you present another modal without dismissing the first, it dismisses the first and calls
 its completion block automatically.
 
 @parem presented The modal to be presented. Must conform to the ModalPresentable protocol. The modal
 is responsible for doing its own sizing, either through frames or auto-layout.
 @parem presentingView The view we want to put the modal over. We will center the modal in the given view.
 If you want it to behave like a traditional UIAlertView, present from [[[UIApplication sharedApplication] delegate] window]. 
 @parem completion Gets called when the modal is dismissed. At present we do not make any sort of
 gaurentees about the thread the completion is called on.
 */
+(void)presentController:(id<ModalPresentable>)presented fromView:(UIView *)presentingView withCompletion:(void (^)(void))completion;
/** passes all the paremeters onto [ModalPresenter presentController:fromView:withCompletion but passes presentingViewController.view in to
 fromView:*/
+(void)presentController:(id <ModalPresentable>) presented fromController:(UIViewController*) presentingViewController withCompletion:(void (^)(void))completion;
/** Dismiss the currently visible modal, and call its completion block. We keep a strong pointer to the presented
 controller as long as it is visible. But we relinquish it after the completion block is completed.*/
+(void)dismissController;

@end


