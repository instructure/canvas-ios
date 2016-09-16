//
//  CKSubmissionType.h
//  CanvasKit
//
//  Created by BJ Homer on 4/10/12.
//  Copyright (c) 2012 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    CKSubmissionUnknownType,
    CKSubmissionTypeOnlineUpload    = 1 << 0,
    CKSubmissionTypeOnlineTextEntry = 1 << 1,
    CKSubmissionTypeOnlineQuiz      = 1 << 2,
    CKSubmissionTypeOnlineURL       = 1 << 3,
    CKSubmissionTypeDiscussionTopic = 1 << 4,
    CKSubmissionTypeMediaRecording  = 1 << 5,
    CKSubmissionTypeExternalTool    = 1 << 6
} CKSubmissionType;

CKSubmissionType submissionTypeForString(NSString *typeString);