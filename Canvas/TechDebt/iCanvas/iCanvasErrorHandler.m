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
    
    

#import <CanvasKit1/CanvasKit1.h>
#import "UIAlertController+TechDebt.h"
#import "iCanvasErrorHandler.h"

@interface iCanvasErrorHandler ()
@end

@implementation iCanvasErrorHandler {
    BOOL _showedAccessTokenError;
    NSMutableDictionary *_errorHistory;
}

+ (id)sharedErrorHandler {
    static iCanvasErrorHandler *_sharedErrorHandler = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedErrorHandler = [[iCanvasErrorHandler alloc] init];
    });
    
    return _sharedErrorHandler;
}

- (id)init
{
    self = [super init];
    if (self) {
        _errorHistory = [NSMutableDictionary new];
    }
    return self;
}

- (void)logError:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
    [self handleError:error displayToUser:NO];
}

- (void)presentError:(NSError *)error
{
    [self handleError:error displayToUser:YES];
}

- (void)handleError:(NSError *)error displayToUser:(BOOL)displayToUser
{
    // handle Access Token errors separately
    if ([[error domain] isEqualToString:CKCanvasErrorDomain]
        && [error code] == 401) {
        
        id message = (error.userInfo)[@"message"];
        // Sometimes, 'message' is apparently not a string. Cause that's useful. Thanks, API.
        if ([message isKindOfClass:[NSString class]] && [message isEqualToString:@"Invalid access token."]) {
            if (!_showedAccessTokenError) {
                // Bad access token error
                [UIAlertController showAlertWithTitle:NSLocalizedString(@"Authentication error", @"Title for an error popup") message:NSLocalizedString(@"Could not authenticate with server", nil) handler:^{
                    _showedAccessTokenError = NO;
                }];
                _showedAccessTokenError = YES;
            }
            return;
        }
    }
    
    // Log malformed URLs
    if([[error domain] isEqualToString:NSURLErrorDomain] && [error code] == NSURLErrorBadURL) {
        NSURL *badURL = error.userInfo[NSURLErrorFailingURLStringErrorKey];
        NSLog(@"Bad URL: %@", badURL.absoluteString);
        return; // never display errors of this kind
    }
    
    if (displayToUser) {
        //Makes sure we only display errors we haven't just displayed.
        NSString *errorMessage = [error localizedDescription];
        NSDictionary *errorUserInfo = [error userInfo];
        
        if (errorUserInfo[@"errors"]) {
            errorMessage = [NSString stringWithFormat:@"%@",
                            errorUserInfo[@"errors"]];
        } else if (errorUserInfo[@"message"]) {
            errorMessage = errorUserInfo[@"message"];
        } else if ([error code] == 401) {
            errorMessage = NSLocalizedString(@"Access denied. Please check your permissions for the action you're trying to complete.", @"Error handling message when a network request has been denied by a server. Specifically with the HTTP 401 error code.");
        }
        
        if ([errorMessage length] == 0 && [[error domain] isEqualToString:CKCanvasErrorDomain]) {
            errorMessage = NSLocalizedString(@"Canvas appears to be unavailable. Please try again later.", nil);
        }
        
        NSDate * timeStamp = [NSDate date];
        
        NSDate *previousTimeStamp = _errorHistory[errorMessage];
        if (!previousTimeStamp || [timeStamp timeIntervalSinceDate:previousTimeStamp] > 30.0) {
            _errorHistory[errorMessage] = timeStamp;
            
            BOOL invalidAccessTokenMessageReturned = [errorMessage isEqualToString:@"Invalid access token."];
            BOOL unsupportedUrlMessageReturned = [errorMessage rangeOfString:@"unsupported URL"].length > 0;
            
            // Supressing two errors that appear to have no impact but are sometimes returned
            if (!invalidAccessTokenMessageReturned && !unsupportedUrlMessageReturned)
            {
                [UIAlertController showAlertWithTitle:NSLocalizedString(@"Error", @"Title for an error popup") message:errorMessage];
            }
        }
    }
}

@end
