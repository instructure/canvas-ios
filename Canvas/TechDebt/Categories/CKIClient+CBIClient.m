//
//  CKIClient+CBIClient.m
//  iCanvas
//
//  Created by Jason Larsen on 11/14/13.
//  Copyright (c) 2013 Instructure. All rights reserved.
//

#import "CKIClient+CBIClient.h"
#import "AFHTTPAvatarImageResponseSerializer.h"

#import <objc/runtime.h>

@import TooLegit;

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

- (Session*)authSession{
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
