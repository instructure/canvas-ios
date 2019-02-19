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
    
    

#import "CKUser.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKUser

@synthesize ident, name, loginId, primaryEmail, displayName, sortableName, sisLoginId, sisUserId, avatarURL;
@synthesize loggedIn, calendarURL, collections;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        [self updateWithInfo:info];
        
        // Right now, if a user exists, it is logged in. This may change in the future.
        self.loggedIn = YES;
    }
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{    
    ident = [info[@"id"] unsignedLongLongValue];
    name = [info objectForKeyCheckingNull:@"name"];
    loginId = [info objectForKeyCheckingNull:@"login_id"];
    primaryEmail = [info objectForKeyCheckingNull:@"primary_email"];
    // When fetching users in a course, email comes in under the email key
    if (!primaryEmail) {
        primaryEmail = [info objectForKeyCheckingNull:@"email"];
    }
    displayName = [info objectForKeyCheckingNull:@"short_name"];
    sortableName = [info objectForKeyCheckingNull:@"sortable_name"];
    sisLoginId = [info objectForKeyCheckingNull:@"sis_login_id"];
    sisUserId = [info objectForKeyCheckingNull:@"sis_user_id"];
    
    NSString *avatarURLString = [info objectForKeyCheckingNull:@"avatar_url"];
    if (avatarURLString) {
        avatarURL = [NSURL URLWithString:avatarURLString];
    }
    
    NSDictionary *calendarDict = [info objectForKeyCheckingNull:@"calendar"];
    if (calendarDict) {
        NSString *urlString = [calendarDict objectForKeyCheckingNull:@"ics"];
        if (urlString) {
            calendarURL = [NSURL URLWithString:urlString];
        }
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<CKUser: %p  (%@)>", self, name];
}

- (NSUInteger)hash {
    return (NSUInteger)self.ident;
}

@end
