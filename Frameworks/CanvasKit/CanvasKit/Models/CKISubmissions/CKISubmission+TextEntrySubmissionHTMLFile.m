//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
