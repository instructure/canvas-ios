//
//  CKStreamMessageItem.m
//  CanvasKit
//
//  Created by Mark Suman on 9/7/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKStreamMessageItem.h"
#import "NSDictionary+CKAdditions.h"
#import "CKAssignment.h"
#import "CKCalendarItem.h"
#import "CKCourse.h"

@interface CKStreamMessageItem()

- (void)updateContextInfoWithURL:(NSURL *)someURL;

@end


@implementation CKStreamMessageItem

@synthesize url, assignmentId, submissionId, calendarEventId;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super initWithInfo:info];
    if (self) {
        NSString *urlString = [info objectForKeyCheckingNull:@"url"];
        if (urlString) {
            url = [NSURL URLWithString:urlString];
            [self updateContextInfoWithURL:url];
        }
    }
    
    return self;
}


- (void)updateContextInfoWithURL:(NSURL *)someURL
{
    NSArray *pathComponents = [someURL pathComponents];
    for (int i=0; i < [pathComponents count]; i++) {
        NSString *pathComponent = pathComponents[i];
        if ([@"/" isEqualToString:pathComponent]) {
            continue;
        }
        else if ([@"courses" isEqualToString:pathComponent]) {
            if (i+1 < [pathComponents count]) {
                self.courseId = [pathComponents[i+1] unsignedLongLongValue];
            }
        }
        else if ([@"assignments" isEqualToString:pathComponent]) {
            if (i+1 < [pathComponents count]) {
                self.assignmentId = [pathComponents[i+1] unsignedLongLongValue];
            }
        }
        else if ([@"submissions" isEqualToString:pathComponent]) {
            if (i+1 < [pathComponents count]) {
                self.submissionId = [pathComponents[i+1] unsignedLongLongValue];
            }
        }
        else if ([@"calendar_events" isEqualToString:pathComponent]) {
            if (i+1 < [pathComponents count]) {
                self.calendarEventId = [pathComponents[i+1] unsignedLongLongValue];
            }
        }
    }
    
}

- (void)populateActionPath
{
    if (self.actionPath) {
        return;
    }
    
    if (self.assignmentId > 0) {
        self.actionPath = @[[CKCourse class], @(self.courseId), [CKAssignment class], @(self.assignmentId)];
    }
    
    if (self.calendarEventId > 0) {
        self.actionPath = @[[CKCourse class], @(self.courseId), [CKCalendarItem class], @(self.calendarEventId)];
    }
}

@end
