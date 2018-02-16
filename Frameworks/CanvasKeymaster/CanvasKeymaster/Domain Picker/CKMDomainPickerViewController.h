//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <UIKit/UIKit.h>
#import <CanvasKit/CanvasKit.h>

@class RACSignal;

@interface CKMDomainPickerViewController : UIViewController

/**
 This indicates whether the user selected default, canvas login, or
 site admin login
*/
@property (nonatomic) CKIAuthenticationMethod authenticationMethod;

/**
* Signal fires when a domain has been selected and connect was pressed.
* Signal sends an NSURL of the selected domain.
*/
- (RACSignal *)selectedADomainSignal;

/**
 * Select the domain
 * The domain selected is whatever text is in the textfield
 */
- (void)sendDomain:(CKIAccountDomain *)domain;

/**
 * Signal fires when a previously logged in user has been selected.
 * Signal sends a CKIClient of the selected user.
 */
- (RACSignal *)selectUserSignal;

@end
