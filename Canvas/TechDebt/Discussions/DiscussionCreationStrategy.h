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
    
    

#import <Foundation/Foundation.h>
#import <CanvasKit1/CanvasKit1.h>

@protocol DiscussionCreationStrategy <NSObject>

@required

- (CKDiscussionTopicType)topicTypeForThreaded:(BOOL)threaded;

- (BOOL)shouldHideThreadedControls;

- (void)postDiscussionTopicForContext:(CKContextInfo *)context
                            withTitle:(NSString *)title
                              message:(NSString *)message
                          attachments:(NSArray *)attachments
                            topicType:(CKDiscussionTopicType)topicType
                       usingCanvasAPI:(CKCanvasAPI *)canvasAPI
                                block:(CKDiscussionTopicBlock)block;

@optional

// The title displayed in the view responsible for posting new discussions
- (NSString *)createDiscussionViewTitle;

@end
