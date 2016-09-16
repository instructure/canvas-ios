//
//  CKCanvasAPI+RealmAssignmentBridge.h
//  iCanvas
//
//  Created by Nathan Perry on 12/1/15.
//  Copyright © 2015 Instructure. All rights reserved.
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
