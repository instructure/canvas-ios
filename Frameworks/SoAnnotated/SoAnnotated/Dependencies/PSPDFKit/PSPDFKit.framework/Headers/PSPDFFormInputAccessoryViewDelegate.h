//
//  PSPDFFormInputAccessoryViewDelegate.h
//  PSPDFKit
//
//  Copyright (c) 2013-2016 PSPDFKit GmbH. All rights reserved.
//
//  THIS SOURCE CODE AND ANY ACCOMPANYING DOCUMENTATION ARE PROTECTED BY INTERNATIONAL COPYRIGHT LAW
//  AND MAY NOT BE RESOLD OR REDISTRIBUTED. USAGE IS BOUND TO THE PSPDFKIT LICENSE AGREEMENT.
//  UNAUTHORIZED REPRODUCTION OR DISTRIBUTION IS SUBJECT TO CIVIL AND CRIMINAL PENALTIES.
//  This notice may not be removed from this file.
//

#import "PSPDFEnvironment.h"

NS_ASSUME_NONNULL_BEGIN

@class PSPDFFormInputAccessoryView;

PSPDF_AVAILABLE_DECL @protocol PSPDFFormInputAccessoryViewDelegate <NSObject>

- (void)doneButtonPressedOnFormInputView:(PSPDFFormInputAccessoryView *)inputView;
- (void)previousButtonPressedOnFormInputView:(PSPDFFormInputAccessoryView *)inputView;
- (void)nextButtonPressedOnFormInputView:(PSPDFFormInputAccessoryView *)inputView;
- (void)clearButtonPressedOnFormInputView:(PSPDFFormInputAccessoryView *)inputView;

- (BOOL)formInputViewShouldEnablePreviousButton:(PSPDFFormInputAccessoryView *)inputView;
- (BOOL)formInputViewShouldEnableNextButton:(PSPDFFormInputAccessoryView *)inputView;
- (BOOL)formInputViewShouldEnableClearButton:(PSPDFFormInputAccessoryView *)inputView;

@end

NS_ASSUME_NONNULL_END
