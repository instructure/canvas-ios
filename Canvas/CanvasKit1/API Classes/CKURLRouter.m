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
    
    

#import "CKURLRouter.h"
#import "CKCanvasAPI.h"
#import "NSString+CKAdditions.h"
#import "CKContextInfo.h"
#import "CKCourse.h"
#import "CKAssignment.h"

@implementation CKDestinationInfo
- (CKContextType)contextType {
    return self.contextInfo.contextType;
}
- (uint64_t)contextIdent {
    return self.contextInfo.ident;
}

- (uint64_t) destinationIdent {
    return [self.destinationIdentString unsignedLongLongValue];
}
@end

@implementation CKURLRouter

#pragma mark -
#pragma mark URL Routing

- (NSURL *)canvasURLForURL:(NSURL *)URL
{
    NSString *existingURLString = [URL absoluteString];
    NSRange rangeOfDelimiter = [existingURLString rangeOfString:@"://"];
    if (rangeOfDelimiter.location == NSNotFound) {
        return URL;
    }
    
    NSString *destinationType = @"";
    BOOL course = [existingURLString rangeOfString:@"/courses/"].location != NSNotFound;
    BOOL group = [existingURLString rangeOfString:@"/groups/"].location != NSNotFound;
    if (course || group) {
        if ([existingURLString rangeOfString:@"/assignments/"].location != NSNotFound) {
            destinationType = @"assignment";
        } else if ([existingURLString rangeOfString:@"/discussion_topics/"].location != NSNotFound) {
            destinationType = @"discussion";
        } else if ([existingURLString rangeOfString:@"/announcements/"].location != NSNotFound) {
            destinationType = @"announcement";
        } else if ([existingURLString rangeOfString:@"/files/"].location != NSNotFound) {
            destinationType = @"file";
        } else if ([existingURLString rangeOfString:@"/folders/"].location != NSNotFound) {
            destinationType = @"folder";
        } else if ([existingURLString rangeOfString:@"/wiki/"].location != NSNotFound) {
            destinationType = @"page";
        } else {
            destinationType = course ? @"course" : @"group";
        }
    }
    
    if ([destinationType length] == 0) {
        return URL;
    }
    
    NSString *newURL = [NSString stringWithFormat:@"x-canvas-%@://%@", destinationType, [existingURLString substringFromIndex:rangeOfDelimiter.location + rangeOfDelimiter.length]];
    
    return [NSURL URLWithString:newURL];
}

static CKDestinationURLType destinationTypeForResultType(NSString *resultType) {
    if ([resultType isEqualToString:@"course"]) {
        return CKDestinationURLTypeCourse;
    }
    if ([resultType isEqualToString:@"assignment"]) {
        return CKDestinationURLTypeAssignment;
    }
    if ([resultType isEqualToString:@"discussion"]) {
        return CKDestinationURLTypeDiscussionTopic;
    }
    if ([resultType isEqualToString:@"announcement"]) {
        return CKDestinationURLTypeAnnouncement;
    }
    if ([resultType isEqualToString:@"file"]) {
        return CKDestinationURLTypeFile;
    }
    if ([resultType isEqualToString:@"folder"]) {
        return CKDestinationURLTypeFolder;
    }
    if ([resultType isEqualToString:@"page"]) {
        return CKDestinationURLTypePage;
    }
    return CKDestinationURLTypeUnknown;
}


- (CKDestinationInfo *)destinationInfoForURL:(NSURL *)url
{
    if ([url.scheme hasPrefix:@"speedgrader"]) {
        return [self speedGraderOpenAssignmentInfoForURL:url];
    }
    else if ([url.scheme hasPrefix:@"x-canvas-"] == NO) {
        CKDestinationInfo *info = [CKDestinationInfo new];
        if ([url.scheme isEqualToString:@"file"]) {
            info.destinationType = CKDestinationURLTypeUnknown;
        }
        else {
            info.destinationType = CKDestinationURLTypeExternal;
        }
        return info;
    }
    
    CKDestinationInfo *info = [CKDestinationInfo new];
    
    NSString *resultType = [url.scheme substringFromIndex:@"x-canvas-".length];
    if ([resultType hasSuffix:@"-array"]) {
        resultType = [resultType substringToIndex:resultType.length - @"-array".length];
        info.destinationIsArray = YES;
    }

    info.destinationType = destinationTypeForResultType(resultType);
    
    NSString *path = url.path;
    if ([path hasPrefix:@"/api/v1"]) {
        path = [path substringFromIndex:@"/api/v1".length];
    }
    
    
#define REGEX(a) ([NSRegularExpression regularExpressionWithPattern:(a) options:0 error:NULL])
#define MATCH(str, regex) ([REGEX(regex) firstMatchInString:(str) options:0 range:(NSRange){0, str.length}])
    
    NSTextCheckingResult *match = nil;

    info.contextInfo = [CKContextInfo new];
    
    if ( (match = MATCH(path, @"^/courses/(\\d+)(.*)")) ) {
        NSString *courseID = [path substringWithRange:[match rangeAtIndex:1]];
        info.destinationIdentString = courseID;
        
        path = [path substringWithRange:[match rangeAtIndex:2]];

        // Note the short-circuiting....
        if ((match = MATCH(path, @"^/assignments/?(\\d*)$")) ||
            (match = MATCH(path, @"^/discussion_topics/?(\\d*)$")) ||
            (match = MATCH(path, @"^/folders/(.*)$")) ||
            (match = MATCH(path, @"^/pages/?(.*)$")) ||
            (match = MATCH(path, @"^/wiki/?(.*)$")) ||
            (match = MATCH(path, @"^/announcements/?(\\d*)$")) )
        {
            info.contextInfo = [[CKContextInfo alloc] initWithContextType:CKContextTypeCourse ident:[courseID unsignedLongLongValue]];
            info.destinationIdentString = [path substringWithRange:[match rangeAtIndex:1]];
        }
    }
    else if ((match = MATCH(path, @"^/users/(\\d+)/folders/(.+)$")) ) {
        NSString *identString = [path substringWithRange:[match rangeAtIndex:1]];
        info.contextInfo = [[CKContextInfo alloc] initWithContextType:CKContextTypeUser ident:[identString unsignedLongLongValue]];
        info.destinationIdentString = [path substringWithRange:[match rangeAtIndex:2]];
    }
    else if ((match = MATCH(path, @"^/files/(\\d+)$")) ||
             (match = MATCH(path, @"^/folders/(\\d+)$"))) {
        info.destinationIdentString = [path substringWithRange:[match rangeAtIndex:1]];
    }
    
    else if ( (match = MATCH(path, @"^/groups/(\\d+)(.*)")) ) {
        NSString *groupID = [path substringWithRange:[match rangeAtIndex:1]];
        info.destinationIdentString = groupID;
        
        path = [path substringWithRange:[match rangeAtIndex:2]];
        
        // Note the short-circuiting....
        if ((match = MATCH(path, @"^/discussion_topics/?(\\d*)$")) ||
            (match = MATCH(path, @"^/folders/(.*)$")) ||
            (match = MATCH(path, @"^/pages/?(.*)$")) ||
            (match = MATCH(path, @"^/wiki/?(.*)$")) ||
            (match = MATCH(path, @"^/announcements/?(\\d*)$")) )
        {
            info.contextInfo = [[CKContextInfo alloc] initWithContextType:CKContextTypeGroup ident:[groupID unsignedLongLongValue]];
            info.destinationIdentString = [path substringWithRange:[match rangeAtIndex:1]];
        }
    }
    
    if (info.destinationIdentString.length == 0) {
        info.destinationIdentString = nil;
    }
    return info;
}


#pragma mark -
#pragma mark Passing info between CanvasKit applications

+ (NSURL *)speedGraderOpenAssignmentURLWithCourse:(CKCourse *)course andAssignment:(CKAssignment *)assignment
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"speedgrader://open/courses/%qu/assignments/%qu",course.ident,assignment.ident]];
}

- (CKDestinationInfo *)speedGraderOpenAssignmentInfoForURL:(NSURL *)url
{
    CKDestinationInfo *openInfo = [CKDestinationInfo new];
    openInfo.destinationType = CKDestinationURLTypeSpeedGraderAssignment;
    openInfo.contextInfo = nil;
    openInfo.destinationIdentString = nil;
    
    NSArray *components = [url pathComponents];
    if ([[url host] isEqualToString:@"open"] && components.count == 5) {
        
        openInfo.contextInfo = [[CKContextInfo alloc] initWithContextType:CKContextTypeCourse ident:[components[2] unsignedLongLongValue]];
        openInfo.destinationIdentString = components[4];
    }
    else {
        NSLog(@"Failed to parse the info out of the SpeedGrader Open Assignment URL. %@",url);
    }
    
    return openInfo;
}

@end
