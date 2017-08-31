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
    
    

#import "AnnouncementCreationIPhoneStrategy.h"

@implementation AnnouncementCreationIPhoneStrategy

- (CKDiscussionTopicType)topicTypeForThreaded:(BOOL)threaded {
    // Announcements are always side comment
    return CKDiscussionTopicTypeSideComment;
}

- (BOOL)shouldHideThreadedControls {
    return YES;
}

- (void)postDiscussionTopicForContext:(CKContextInfo *)context
                            withTitle:(NSString *)title
                              message:(NSString *)message
                          attachments:(NSArray *)attachments
                            topicType:(CKDiscussionTopicType)topicType
                       usingCanvasAPI:(CKCanvasAPI *)canvasAPI
                                block:(CKDiscussionTopicBlock)block
{
    // Topic type is ignored because announcements don't support it.
    [canvasAPI postAnnouncementForContext:context
                                withTitle:title
                                  message:message
                              attachments:attachments
                                    block:block];
}

- (NSString *)createDiscussionViewTitle
{
    return NSLocalizedString(@"Announcement", @"Title of the new announcement view");
}

@end
