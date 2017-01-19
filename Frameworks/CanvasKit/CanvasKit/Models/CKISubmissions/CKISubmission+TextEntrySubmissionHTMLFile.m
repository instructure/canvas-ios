//
//  CKISubmission+TextEntrySubmissionHTMLFile.m
//  iCanvas
//
//  Created by Derrick Hathaway on 9/22/14.
//  Copyright (c) 2014 Instructure. All rights reserved.
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
