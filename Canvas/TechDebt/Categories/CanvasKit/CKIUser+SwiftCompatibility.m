//
//  CKIUser+SwiftCompatibility.m
//  
//
//  Created by Nathan Perry on 7/30/15.
//
//

#import "CKIUser+SwiftCompatibility.h"

@implementation CKIUser (SwiftCompatibility)

-(SessionUser *)swiftUser {
    return [[SessionUser alloc] initWithId:self.id name:self.name loginID:self.loginID sortableName:self.sortableName email:self.email avatarURL:self.avatarURL];
}

@end
