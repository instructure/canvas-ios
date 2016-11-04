
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

@interface CKOAuthWebLoginViewController : UIViewController <UIWebViewDelegate>

@property (copy) void (^finishedBlock)(NSError *error, NSString *accessToken, CKUser *user);

@property (weak) IBOutlet UIWebView *webView;

@property BOOL forceCanvasLogin;

@property (copy) NSURL *baseURL;
@property (copy) NSString *clientID;
@property (copy) NSString *clientSecret;

@property (copy, readonly) NSString *accessToken;
@property (strong, readonly) CKUser *user;

@property (weak) CKCanvasAPI *canvasAPI;

@end
