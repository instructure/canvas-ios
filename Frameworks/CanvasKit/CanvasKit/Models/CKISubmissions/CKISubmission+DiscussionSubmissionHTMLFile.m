//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CKISubmission+DiscussionSubmissionHTMLFile.h"

#import "CKIDiscussionEntry.h"
@import ReactiveObjC;

@interface CKIDiscussionEntry (JSONFormattingForSubmission)

- (NSString *)JSONStringForSubmissionFile;
@end

@implementation CKIDiscussionEntry (JSONFormattingForSubmission)

- (NSString *)JSONStringForSubmissionFile
{
    NSDateFormatter *dateFormatterDate = [[NSDateFormatter alloc] init];
    NSDateFormatter *dateFormatterTime = [[NSDateFormatter alloc] init];
    [dateFormatterDate setDateFormat:@"MMM d"];
    [dateFormatterTime setTimeStyle:NSDateFormatterShortStyle];
    NSString *formattedUpdatedAt = [NSString stringWithFormat:@"%@ at %@",
                                    [dateFormatterDate stringFromDate:self.updatedAt],
                                    [dateFormatterTime stringFromDate:self.updatedAt]];
    
    NSArray *attachmentInfoArray = @[];
    if (self.attachment) {
        attachmentInfoArray = [MTLJSONAdapter JSONArrayFromModels:@[self.attachment]];
    }
    
    NSDictionary *entryInfo = @{@"internalIdent": self.id,
                                @"date": formattedUpdatedAt,
                                @"entryMessage": self.message,
                                @"attachments": attachmentInfoArray,
                                @"userName": self.userName};
    
    NSError *error;
    NSString *entryJSON;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:entryInfo options:NSJSONWritingPrettyPrinted error:&error];
    if (! jsonData) {
        NSLog(@"Error getting json data from dictionary: %@", error);
    } else {
        entryJSON = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return entryJSON;
}

@end

@implementation CKISubmission (DiscussionSubmissionHTMLFile)

- (NSURL *)urlForCachedDiscussionEntriesHTMLFile
{
    NSString *subdirectory = [[NSUUID UUID] UUIDString];
    NSString *filename = @"discussion-entries.html";

    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = cachePaths.firstObject;
    NSString *path = [NSString stringWithFormat:@"%@/submissions/v1/%@/%@", cachePath, subdirectory, filename];
    
    return [NSURL fileURLWithPath:path];
}

- (NSString *)relativePathForResource:(NSString *)resource withExtension:(NSString *)type {
    NSURL *bundleResourceURL = [[NSBundle mainBundle] resourceURL];
    
    NSURL *resourceURL = [[NSBundle mainBundle] URLForResource:resource withExtension:type];
    NSURLComponents *components = [NSURLComponents componentsWithURL:resourceURL resolvingAgainstBaseURL:YES];
    return [components URLRelativeToURL:bundleResourceURL].path;
}

- (NSString *)relativePathToResourcesDir
{
    NSMutableArray *resourcePathComponents = [[[[NSBundle bundleForClass:[CKISubmission class]] resourcePath] pathComponents] mutableCopy];
    NSMutableArray *cachePathComponents = [[[[self urlForCachedDiscussionEntriesHTMLFile] URLByDeletingLastPathComponent] pathComponents] mutableCopy];

    while ([resourcePathComponents.firstObject isEqualToString:cachePathComponents.firstObject]) {
        [resourcePathComponents removeObjectAtIndex:0];
        [cachePathComponents removeObjectAtIndex:0];
    }

    return [[[cachePathComponents.rac_sequence map:^id(id value) {
        return @"..";
    }] concat:resourcePathComponents.rac_sequence].array componentsJoinedByString:@"/"];
}


- (NSString *)htmlFileContentStringForDiscussionEntries {
    
    NSString *relativePathToResourcesDir = [self relativePathToResourcesDir];
    NSString *htmlReplacedString =[NSString stringWithFormat:@""
                                   @"<!DOCTYPE html>"
                                   @"<html lang=\"en\">"
                                   @"<head>"
                                   @"<meta charset=\"utf-8\" />"
                                   @"<title>Discussion Topic</title>"
                                   @"<link rel=\"stylesheet\" href=\"%@/discussion_submissions.css\" type=\"text/css\" />"
                                   @"<script type=\"text/javascript\" src=\"%@/jquery-1.4.2.min.js\"></script>"
                                   @"<script type=\"text/javascript\" src=\"%@/jquery.json-2.2.min.js\"></script>"
                                   @"<script type=\"text/javascript\" src=\"%@/discussion_submissions.js\"></script>"
                                   @"</head>"
                                   @"<body>"
                                   @"<div id=\"entries\">"
                                   @"</div>"
                                   @"</body>"
                                   @"</html>", relativePathToResourcesDir, relativePathToResourcesDir, relativePathToResourcesDir, relativePathToResourcesDir];
    
    NSMutableString *htmlStringWithJavascript = [NSMutableString stringWithString:htmlReplacedString];
    
    [htmlStringWithJavascript appendString:@"<script type=\"text/javascript\">"];
    for (CKIDiscussionEntry *entry in self.discussionEntries) {
        [htmlStringWithJavascript appendString:[NSString stringWithFormat:@"addEntry(%@);\n", [entry JSONStringForSubmissionFile]]];
    }
    [htmlStringWithJavascript appendString:@"</script>"];
    
    return htmlStringWithJavascript;
}


- (void)createDiscussionEntriesHTMLFileAtCacheURL:(NSURL *)cachedURL forSubmission:(CKISubmission *)submission {
    [[NSFileManager defaultManager] createDirectoryAtPath:[[cachedURL path] stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *htmlStringWithJavascript = [self htmlFileContentStringForDiscussionEntries];
    [[NSFileManager defaultManager] createFileAtPath:[cachedURL path] contents:[htmlStringWithJavascript dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

- (NSURL *)urlForLocalDiscussionEntriesHTMLFile {
    NSURL *cacheURL = self.urlForCachedDiscussionEntriesHTMLFile;
    [self createDiscussionEntriesHTMLFileAtCacheURL:cacheURL forSubmission:self];
    return cacheURL;
}

@end
