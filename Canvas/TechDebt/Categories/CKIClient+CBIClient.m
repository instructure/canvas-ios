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
    CKIClient *client = [[CKIClient alloc] initWithBaseURL:self.baseURL];
    [client setValue:self.accessToken forKey:@"accessToken"];
    [client setValue:self.currentUser forKey:@"currentUser"];
    [client setValue:self.actAsUserID forKey:@"actAsUserID"];

    [client setResponseSerializer:[AFHTTPAvatarImageResponseSerializer new]];

    return client;
}

- (Session *)authSession {
    Session *session = objc_getAssociatedObject(self, @selector(authSession));
    if (session != nil && [session isKindOfClass:[Session class]]) {
        return session;
    }
    
    
    NSString *masqueradeID = self.actAsUserID.length > 0 ? self.actAsUserID : nil;

    session = [[Session alloc] initWithBaseURL:self.baseURL user:self.currentUser.sessionUser token:self.accessToken masqueradeAsUserID:masqueradeID];
    
    objc_setAssociatedObject(self, @selector(authSession), session, OBJC_ASSOCIATION_RETAIN);
    return session;
}


@end
