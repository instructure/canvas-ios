//
//  CKSubmissionType.m
//  CanvasKit
//
//  Created by BJ Homer on 4/10/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import "CKSubmissionType.h"

CKSubmissionType submissionTypeForString(NSString *typeString) {
    
    CKSubmissionType type = CKSubmissionUnknownType;
    if ([typeString isEqual:@"online_upload"]) {
        type = CKSubmissionTypeOnlineUpload;
    }
    else if ([typeString isEqual:@"online_text_entry"]) {
        type = CKSubmissionTypeOnlineTextEntry;
    }
    else if ([typeString isEqual:@"online_quiz"]) {
        type = CKSubmissionTypeOnlineQuiz;
    }
    else if ([typeString isEqual:@"online_url"]) {
        type = CKSubmissionTypeOnlineURL;
    }
    else if ([typeString isEqual:@"discussion_topic"]) {
        type = CKSubmissionTypeDiscussionTopic;
    }
    else if ([typeString isEqual:@"media_recording"]) {
        type = CKSubmissionTypeMediaRecording;
    } else if ([typeString isEqual:@"external_tool"]) {
        type = CKSubmissionTypeExternalTool;
    }
    return type;
}