
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
    
    

#import "CKUserAvatar.h"
#import "NSDictionary+CKAdditions.h"

@implementation CKUserAvatar

@synthesize type, URL, token, displayName;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        [self setTypeFromString:[info objectForKeyCheckingNull:@"type"]];
        token = [info objectForKeyCheckingNull:@"token"];
        displayName = [info objectForKeyCheckingNull:@"display_name"];
        NSString *urlString = [info objectForKeyCheckingNull:@"url"];
        if (urlString) {
            URL = [NSURL URLWithString:urlString];
        }
    }
    return self;
}

- (void)setTypeFromString:(NSString *)aString
{
    if ([aString isEqualToString:@"gravatar"]) {
        type = CKUserAvatarTypeGravatar;
    }
    else if ([aString isEqualToString:@"twitter"]) {
        type = CKUserAvatarTypeTwitter;
    }
    else if ([aString isEqualToString:@"linked_in"]) {
        type = CKUserAvatarTypeLinkedIn;
    }
    else if ([aString isEqualToString:@"attachment"]) {
        type = CKUserAvatarTypeAttachement;
    }
    else if ([aString isEqualToString:@"no_pic"]) {
        type = CKUserAvatarTypeNoPic;
    }
}

- (NSUInteger)hash {
    return self.URL.hash;
}

@end
