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
    
    

#import "CKCanvasAPI+RealmAssignmentBridge.h"

@interface CKCanvasAPI (Uploading)
- (void)postFileURLs:(NSArray *)files asSubmissionForAssignment:(CKAssignment *)assignment progressBlock:(void(^)(float progress))progressBlock completionBlock:(CKSubmissionBlock)block;
- (void)postMediaURL:(NSURL *)mediaURL asSubmissionForAssignment:(CKAssignment *)assignment progressBlock:(void(^)(float progress))progressBlock completionBlock:(CKSubmissionBlock)block;
- (void)postHTML:(NSString *)html asSubmissionForAssignment:(CKAssignment *)assignment completionBlock:(CKSubmissionBlock)block;
- (void)postURL:(NSURL *)contentURL asSubmissionForAssignment:(CKAssignment *)assignment completionBlock:(CKSubmissionBlock)block;

- (void)postEntry:(NSString *)entryText withAttachments:(NSArray *)attachments toDiscussionTopic:(CKDiscussionTopic *)topic block:(CKDiscussionEntryBlock)block;
- (void)postReply:(NSString *)replyText withAttachments:(NSArray *)attachments toDiscussionEntry:(CKDiscussionEntry *)entry inTopic:(CKDiscussionTopic *)topic block:(CKDiscussionEntryBlock)block;
@end


@implementation CKCanvasAPI (RealmAssignmentBridge)

+(CKSubmissionBlock)blockWithRealmNotificationForAssignment:(CKAssignment *)assignment session:(Session *)session block:(CKSubmissionBlock)block {
    return ^(NSError *error, BOOL isFinalValue, CKSubmission *attempt) {
        if (!error) {
            // TODO: SoPersistent MBL-5774
//            NSString *assignmentID = [NSString stringWithFormat:@"%zd", assignment.ident];
//            NSString *courseID = [NSString stringWithFormat:@"%zd", assignment.courseIdent];
//            [AssignmentFactory createdSubmissionForAssignmentWithID:assignmentID courseID:courseID session:session completion:^(AssignmentUpdate update) {
//            }];
        }
        block(error, isFinalValue, attempt);
    };
}

+(CKDiscussionEntryBlock)blockWithRealmNotificationForDiscussion:(CKDiscussionTopic *)discussionTopic session:(Session *)session block:(CKDiscussionEntryBlock)block {
    return ^(NSError *error, CKDiscussionEntry *entry) {
        if (!error) {
            // TODO: SoPersistent MBL-5774
//            NSString *discussionID = [NSString stringWithFormat:@"%zd", discussionTopic.ident];
//            NSString *courseID = [NSString stringWithFormat:@"%zd", discussionTopic.contextInfo.ident];
//            [AssignmentFactory createdSubmissionForDiscussionWithID:discussionID courseID:courseID session:session completion:^(AssignmentUpdate update) {
//            }];
        }
        block(error, entry);
    };
}

-(void)postFileURLs:(NSArray *)files asSubmissionForAssignment:(CKAssignment *)assignment session:(Session *)session progressBlock:(void (^)(float))progressBlock completionBlock:(CKSubmissionBlock)block {
    CKSubmissionBlock completion = [CKCanvasAPI blockWithRealmNotificationForAssignment:assignment session:session block:block];
    [self postFileURLs:files asSubmissionForAssignment:assignment progressBlock:progressBlock completionBlock:completion];
}

-(void)postHTML:(NSString *)html asSubmissionForAssignment:(CKAssignment *)assignment session:(Session *)session completionBlock:(CKSubmissionBlock)block {
    CKSubmissionBlock completion = [CKCanvasAPI blockWithRealmNotificationForAssignment:assignment session:session block:block];
    [self postHTML:html asSubmissionForAssignment:assignment completionBlock:completion];
}

-(void)postMediaURL:(NSURL *)mediaURL asSubmissionForAssignment:(CKAssignment *)assignment session:(Session *)session progressBlock:(void (^)(float))progressBlock completionBlock:(CKSubmissionBlock)block {
    CKSubmissionBlock completion = [CKCanvasAPI blockWithRealmNotificationForAssignment:assignment session:session block:block];
    [self postMediaURL:mediaURL asSubmissionForAssignment:assignment progressBlock:progressBlock completionBlock:completion];
}

-(void)postURL:(NSURL *)contentURL asSubmissionForAssignment:(CKAssignment *)assignment session:(Session *)session completionBlock:(CKSubmissionBlock)block {
    CKSubmissionBlock completion = [CKCanvasAPI blockWithRealmNotificationForAssignment:assignment session:session block:block];
    [self postURL:contentURL asSubmissionForAssignment:assignment completionBlock:completion];
}

-(void)postEntry:(NSString *)entryText withAttachments:(NSArray *)attachments toDiscussionTopic:(CKDiscussionTopic *)topic session:(Session*)session block:(CKDiscussionEntryBlock)block {
    CKDiscussionEntryBlock completion = [CKCanvasAPI blockWithRealmNotificationForDiscussion:topic session:session block:block];
    [self postEntry:entryText withAttachments:attachments toDiscussionTopic:topic block:completion];
}

-(void)postReply:(NSString *)replyText withAttachments:(NSArray *)attachments toDiscussionEntry:(CKDiscussionEntry *)entry inTopic:(CKDiscussionTopic *)topic session:(Session*) session block:(CKDiscussionEntryBlock)block {
    CKDiscussionEntryBlock completion = [CKCanvasAPI blockWithRealmNotificationForDiscussion:topic session:session block:block];
    [self postReply:replyText withAttachments:attachments toDiscussionEntry:entry inTopic:topic block:completion];
}

@end
