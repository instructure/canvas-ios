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
@class CKCanvasAPI, CKUser;

@interface CKOAuthController : UIViewController
<UIWebViewDelegate, UITextFieldDelegate> 

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *connectBottomConstraint;
@property (copy) void (^finishedBlock)(NSError *error, NSString *accessToken, CKUser *user);
@property (weak) CKCanvasAPI *canvasAPI;

- (void)doLoginForDomain:(NSString *)domain; // `domain` should look like 'example.instructure.com'

@end
