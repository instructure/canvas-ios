//
//  ModalPresenter.h
//  iCanvas
//
//  Created by Nathan Perry on 3/31/15.
//  Copyright (c) 2015 Instructure. All rights reserved.
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


