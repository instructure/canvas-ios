//
//  CKStreamAnnouncementItem.m
//  CanvasKit
//
//  Created by Mark Suman on 8/11/11.
//  Copyright (c) 2011 Instructure, Inc. All rights reserved.
//

#import "CKStreamAnnouncementItem.h"
#import "CKCourse.h"
#import "CKGroup.h"
#import "CKAnnouncement.h"

@implementation CKStreamAnnouncementItem

@synthesize announcementIdent;

- (id)initWithInfo:(NSDictionary *)info
{
    self = [super initWithInfo:info];
    if (self) {
        // set the subclass-specific ivars
        announcementIdent = [info[@"announcement_id"] unsignedLongLongValue];
    }
    
    return self;
}

- (void)populateActionPath
{
    if (self.actionPath) {
        return;
    }
    
    if (self.courseId) {
        self.actionPath = @[[CKCourse class], @(self.courseId), [CKAnnouncement class], @(self.announcementIdent)];
    } else if (self.groupId) {
        self.actionPath = @[[CKGroup class], @(self.groupId), [CKAnnouncement class], @(self.announcementIdent)];
    }
}

@end
