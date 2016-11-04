
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
