
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
    
    

#import "CKCollection.h"
#import "NSDictionary+CKAdditions.h"


@implementation CKCollection

@synthesize ident, name, visibility, isFollowedByUser, followersCount, itemsCount, collectionItems, rawInfo;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        ident = [info[@"id"] unsignedLongLongValue];
        name = [info objectForKeyCheckingNull:@"name"];
        isFollowedByUser = [[info objectForKeyCheckingNull:@"followed_by_user"] boolValue];
        followersCount = [[info objectForKeyCheckingNull:@"followers_count"] intValue];
        itemsCount = [[info objectForKeyCheckingNull:@"items_count"] intValue];
        [self setVisibilityWithString:[info objectForKeyCheckingNull:@"visibility"]];
        
        if (info.count > 6) {
            NSLog(@"The Collections API is returning new information! \n%@", info);
        }
    }
    return self;
}

- (void)setVisibilityWithString:(NSString *)aString
{
    if ([aString isEqualToString:@"public"]) {
        visibility = CKCollectionVisibilityPublic;
    } 
    else if ([aString isEqualToString:@"private"]) {
        visibility = CKCollectionVisibilityPrivate;
    } 
    else {
        NSAssert(NO, @"Unknown Collection visibility type: %@*visibility", aString);
    }
}

- (NSUInteger)hash {
    return ident;
}

@end
