//
// Created by Jason Larsen on 1/6/14.
// Copyright (c) 2014 Instructure. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CanvasKit/CanvasKit.h>

@class RACSignal;

@interface CKMDomainPickerViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicatorView;

/**
 This indicates whether the user selected default, canvas login, or
 site admin login
*/
@property (nonatomic) CKIAuthenticationMethod authenticationMethod;

/**
* Signal fires when a domain has been selected and connect was pressed.
* Signal sends an NSURL of the selected domain.
*/
- (RACSignal *)selecteADomainSignal;

/**
 * Select the domain
 * The domain selected is whatever text is in the textfield
 */
- (void)sendDomain;

/**
 * Signal fires when a previously logged in user has been selected.
 * Signal sends a CKIClient of the selected user.
 */
- (RACSignal *)selectUserSignal;


/**
 Prepopulate the domain picker with the given domain.
 */
- (void)prepopulateWithDomain:(NSString *)domain;

@end