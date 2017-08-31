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
    
    

// API
#import "CKCanvasAPI.h"
#import "CKCanvasAPI+Modules.h"
#import "CKCanvasAPI+Quizzes.h"
#import "CKCanvasAPI+ActivityStream.h"
#import "CKCanvasAPI+Conversations.h"
#import "CKCanvasAPI+ExternalTool.h"
#import "CKCanvasAPI+UpcomingEvents.h"
#import "CKAPICredentials.h"
#import "CKAttachmentManager.h"
#import "CKPaginationInfo.h"

// Models
#import "CKAnnouncement.h"
#import "CKCalendarItem.h"
#import "CKCollection.h"
#import "CKCollectionItem.h"
#import "CKSubmissionComment.h"
#import "CKContentLock.h"
#import "CKContextInfo.h"
#import "CKEnrollment.h"
#import "CKExternalTool.h"
#import "CKFolder.h"
#import "CKMediaServer.h"
#import "CKModelObject.h"
#import "CKPage.h"
#import "CKQuiz.h"
#import "CKStudent.h"
#import "CKTab.h"
#import "CKTerm.h"
#import "CKTodoItem.h"

#import "CKAssignment.h"
#import "CKAssignmentGroup.h"
#import "CKAssignmentOverride.h"

#import "CKAttachment.h"
#import "CKCommentAttachment.h"
#import "CKEmbeddedMediaAttachment.h"

#import "CKConversation.h"
#import "CKConversationAttachment.h"
#import "CKConversationMessage.h"
#import "CKConversationRecipient.h"
#import "CKConversationRelatedSubmission.h"

#import "CKDiscussionEntry.h"
#import "CKDiscussionTopic.h"

#import "CKGroup.h"
#import "CKGroupMembership.h"

#import "CKRubric.h"
#import "CKRubricCriterion.h"
#import "CKRubricCriterionRating.h"
#import "CKRubricAssessment.h"
#import "CKRubricCriterion.h"
#import "CKRubricCriterionRating.h"

#import "CKModule.h"
#import "CKModuleItem.h"
#import "CKModuleItemCompletionRequirement.h"

#import "CKStreamItem.h"
#import "CKStreamAnnouncementItem.h"
#import "CKStreamConversationItem.h"
#import "CKStreamDiscussionItem.h"
#import "CKStreamSubmissionItem.h"
#import "CKStreamMessageItem.h"
#import "CKActivityStreamSummary.h"

#import "CKSubmission.h"
#import "CKSubmissionAttempt.h"
#import "CKSubmissionType.h"

#import "CKUser.h"
#import "CKUserAvatar.h"

#import "CKRemoteImageButton.h"
