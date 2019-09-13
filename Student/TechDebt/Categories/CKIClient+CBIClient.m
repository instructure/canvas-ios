//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

#import "CKIClient+CBIClient.h"
#import "AFHTTPAvatarImageResponseSerializer.h"

#import <objc/runtime.h>

@import CanvasCore;

NSString * const CBICourseColorUpdatedNotification = @"CBICourseColorUpdatedNotification";
NSString * const CBICourseColorUpdatedCourseIDKey = @"CBICourseColorUpdatedCourseIDKey";
NSString * const CBICourseColorUpdatedValue = @"CBICourseColorUpdatedValue";


@interface CKIUser (CBIClient)
@property (nonatomic, readonly) SessionUser *sessionUser;
@end

@implementation CKIUser (CBIClient)
- (SessionUser *)sessionUser {
    return [[SessionUser alloc] initWithId:self.id name:self.name loginID:self.loginID sortableName:self.sortableName email:self.email avatarURL:self.avatarURL];
}
@end

@implementation CKIClient (CBIClient)

/**
* Creates a client that uses an image response serializer instead of
*/
- (CKIClient *)imageClient
{
    CKIClient *client = [[CKIClient alloc] initWithBaseURL:self.baseURL
                                                     token:self.accessToken
                                              refreshToken:self.refreshToken
                                                  clientID:self.clientID
                                              clientSecret:self.clientSecret];
    client.currentUser = self.currentUser;
    client.actAsUserID = self.actAsUserID;
    [client setResponseSerializer:[AFHTTPAvatarImageResponseSerializer new]];

    return client;
}

@end
