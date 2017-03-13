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

#import "CKISubmission+TextEntrySubmissionHTMLFile.h"

@implementation CKISubmission (TextEntrySubmissionHTMLFile)

- (NSURL *)urlForTextEntryLocalHTMLFile {
    NSString *subdirectory = [[NSUUID UUID] UUIDString];    
    NSString *filename = [NSString stringWithFormat:@"text-entry%lu.html", (unsigned long)self.attempt];
    
    
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = cachePaths.firstObject;
    NSString *path = [NSString stringWithFormat:@"%@/submissions/v1/%@/%@", cachePath, subdirectory, filename];
    
    return [NSURL fileURLWithPath:path];
}

- (NSURL *)urlForLocalTextEntryHTMLFile {
    NSURL *url = [self urlForTextEntryLocalHTMLFile];
    
    NSString *fullBody = [NSString stringWithFormat:@"<html><head><meta charset='utf-8' /></head><body style='margin: 40px; padding: 50px; font-size: 2em;'>%@</body></html>", self.body];
    
    [[NSFileManager defaultManager] createDirectoryAtPath:[[url path] stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    [[NSFileManager defaultManager] createFileAtPath:[url path] contents:[fullBody dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    return url;
}

@end
