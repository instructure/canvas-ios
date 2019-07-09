//
// This file is part of Canvas.
// Copyright (C) 2016-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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