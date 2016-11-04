
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
    
    

#import "CKCollectionItem.h"
#import "NSDictionary+CKAdditions.h"
#import "CKUser.h"
#import "ISO8601DateFormatter.h"

@implementation CKCollectionItem

@synthesize ident, collectionId, title, author, itemType, dateCreated, linkURL, postCount, upvoteCount, hasUpvoteByUser;
@synthesize rootItemId, isImagePending, imageURL, itemDescription, htmlPreview, authorComment, URL;
@synthesize comments, rawInfo;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        [self updateWithInfo:info];
    }
    return self;
}

- (void)updateWithInfo:(NSDictionary *)info
{
    ident = [info[@"id"] unsignedLongLongValue];
    collectionId = [info[@"collection_id"] unsignedLongLongValue];
    title = [info objectForKeyCheckingNull:@"title"];
    [self setItemTypeFromString:[info objectForKeyCheckingNull:@"item_type"]];
    postCount = [info[@"post_count"] intValue];
    upvoteCount = [info[@"upvote_count"] intValue];
    hasUpvoteByUser = [info[@"upvote_by_user"] boolValue];
    rootItemId = [info[@"root_item_id"] unsignedLongLongValue];
    isImagePending = [[info objectForKeyCheckingNull:@"image_pending"] boolValue];
    itemDescription = [info objectForKeyCheckingNull:@"description"];
    htmlPreview = [info objectForKeyCheckingNull:@"html_preview"];
    authorComment = [info objectForKeyCheckingNull:@"user_comment"];
    
    id rawDateStr = info[@"created_at"]; // might be an NSNull
    if ([rawDateStr isKindOfClass:[NSString class]]) {
        ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
        dateCreated = [formatter dateFromString:rawDateStr];
    }
    
    NSDictionary *authorInfo = [info objectForKeyCheckingNull:@"user"];
    if (authorInfo) {
        author = [CKUser new];
        author.ident = [authorInfo[@"id"] unsignedLongLongValue];
        author.name = [authorInfo objectForKeyCheckingNull:@"display_name"];
        NSString *urlString = [authorInfo objectForKeyCheckingNull:@"avatar_image_url"];
        if (urlString) {
            author.avatarURL = [NSURL URLWithString:urlString];
        }
    }
    
    NSString *linkURLString = [info objectForKeyCheckingNull:@"link_url"];
    if (linkURLString) {
        linkURL = [NSURL URLWithString:linkURLString];
    }
    NSString *imageURLString = [info objectForKeyCheckingNull:@"image_url"];
    if (imageURLString) {
        imageURL = [NSURL URLWithString:imageURLString];
    }
    NSString *urlString = [info objectForKeyCheckingNull:@"url"];
    if (urlString) {
        URL = [NSURL URLWithString:urlString];
    }
    
    if (title == nil) {
        NSString *path = [self.linkURL.path isEqualToString:@"/"] ? @"" : self.linkURL.path;
        self.title = [NSString stringWithFormat:@"%@%@", self.linkURL.host, path];
    }
    
    if (info.count > 17) {
        NSLog(@"The Collection Info API is returning new information! \n%@", info);
    }
}

- (void)setItemTypeFromString:(NSString *)aString
{
    if ([aString isEqualToString:@"url"]) {
        itemType = CKCollectionItemTypeURL;
    }
}

- (NSString *)timeSinceCreation
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit |NSYearCalendarUnit;
    NSDateComponents *components = [currentCalendar components:unitFlags fromDate:dateCreated toDate:[NSDate date] options:0];
    
    if (components.year > 2) {
        NSString *baseString = NSLocalizedString(@"%d years ago", @"time since creation (2 or more years)");
        return [NSString stringWithFormat:baseString, components.year];
    }
    else if (components.year > 1) {
        return NSLocalizedString(@"1 year ago", @"time since creation");
    }
    else if (components.month > 2) {
        NSString *baseString = NSLocalizedString(@"%d months ago", @"time since creation (2 or more months)");
        return [NSString stringWithFormat:baseString, components.month];
    }
    else if (components.month > 1) {
        return NSLocalizedString(@"1 month ago", @"time since creation");
    }
    else if (components.day > 2) {
        NSString *baseString = NSLocalizedString(@"%d days ago", @"time since creation (2 or more days)");
        return [NSString stringWithFormat:baseString, components.day];
    }
    else if (components.day > 1) {
        return NSLocalizedString(@"1 day ago", @"time since creation");
    }
    else if (components.hour > 2) {
        NSString *baseString = NSLocalizedString(@"%d hours ago", @"time since creation (2 or more hours)");
        return [NSString stringWithFormat:baseString, components.hour];
    }
    else if (components.hour > 1) {
        return NSLocalizedString(@"1 hour ago", @"time since creation");
    }
    else if (components.minute > 2) {
        NSString *baseString = NSLocalizedString(@"%d minutes ago", @"time since creation (2 or more minutes)");
        return [NSString stringWithFormat:baseString, components.minute];
    }
    else if (components.minute > 1) {
        return NSLocalizedString(@"1 minute ago", @"time since creation");
    }
    return NSLocalizedString(@"moments ago", @"time since creation (less than 1 minute)");
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<CKCollectionItem: %p  (%u)>", self, itemType];
}

- (NSUInteger)hash {
    return ident;
}

@end
