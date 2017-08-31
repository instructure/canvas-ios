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