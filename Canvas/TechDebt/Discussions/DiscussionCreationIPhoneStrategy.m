
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
    
    

#import "DiscussionCreationIPhoneStrategy.h"

@implementation DiscussionCreationIPhoneStrategy

- (CKDiscussionTopicType)topicTypeForThreaded:(BOOL)threaded
{
    if (threaded) {
        return CKDiscussionTopicTypeThreaded;
    }
    else {
        return CKDiscussionTopicTypeSideComment;
    }
}

- (BOOL)shouldHideThreadedControls
{
    return NO;
}

- (void)postDiscussionTopicForContext:(CKContextInfo *)context
                            withTitle:(NSString *)title
                              message:(NSString *)message
                          attachments:(NSArray *)attachments
                            topicType:(CKDiscussionTopicType)topicType
                       usingCanvasAPI:(CKCanvasAPI *)canvasAPI
                                block:(CKDiscussionTopicBlock)block
{
    [canvasAPI postDiscussionTopicForContext:context
                                   withTitle:title
                                     message:message
                                 attachments:attachments
                                   topicType:topicType
                                       block:block];
}

- (NSString *)createDiscussionViewTitle
{
    return NSLocalizedString(@"Discussion", @"Title of the new discussion view");
}

@end
