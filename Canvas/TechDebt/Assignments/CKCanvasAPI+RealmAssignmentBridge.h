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
    
    

#import <CanvasKit1/CanvasKit1.h>
#import "CKCanvasAPI.h"
@import TooLegit;

@interface CKCanvasAPI (RealmAssignmentBridge)

- (void)postFileURLs:(NSArray *)files asSubmissionForAssignment:(CKAssignment *)assignment session: (Session*) session progressBlock:(void(^)(float progress))progressBlock completionBlock:(CKSubmissionBlock)block;
- (void)postMediaURL:(NSURL *)mediaURL asSubmissionForAssignment:(CKAssignment *)assignment session: (Session*) session progressBlock:(void(^)(float progress))progressBlock completionBlock:(CKSubmissionBlock)block;
- (void)postHTML:(NSString *)html asSubmissionForAssignment:(CKAssignment *)assignment session: (Session*) session completionBlock:(CKSubmissionBlock)block;
- (void)postURL:(NSURL *)contentURL asSubmissionForAssignment:(CKAssignment *)assignment session: (Session*) session completionBlock:(CKSubmissionBlock)block;

-(void)postEntry:(NSString *)entryText withAttachments:(NSArray *)attachments toDiscussionTopic:(CKDiscussionTopic *)topic session:(Session*)session block:(CKDiscussionEntryBlock)block;
-(void)postReply:(NSString *)replyText withAttachments:(NSArray *)attachments toDiscussionEntry:(CKDiscussionEntry *)entry inTopic:(CKDiscussionTopic *)topic session:(Session*) session block:(CKDiscussionEntryBlock)block;
@end
