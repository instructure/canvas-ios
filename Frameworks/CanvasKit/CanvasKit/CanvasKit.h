//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
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

#import <UIKit/UIKit.h>

//! Project version number for CanvasKit.
FOUNDATION_EXPORT double CanvasKitVersionNumber;

//! Project version string for CanvasKit.
FOUNDATION_EXPORT const unsigned char CanvasKitVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CanvasKit/PublicHeader.h>


#import <CanvasKit/CKIUser.h>
#import <CanvasKit/Constants.h>

#pragma mark - Models

#import <CanvasKit/CKIAccountDomain.h>
#import <CanvasKit/CKIActivityStreamItem.h>
#import <CanvasKit/CKIActivityStreamDiscussionTopicItem.h>
#import <CanvasKit/CKIActivityStreamAnnouncementItem.h>
#import <CanvasKit/CKIActivityStreamConversationItem.h>
#import <CanvasKit/CKIActivityStreamMessageItem.h>
#import <CanvasKit/CKIActivityStreamConferenceItem.h>
#import <CanvasKit/CKIActivityStreamCollaborationItem.h>
#import <CanvasKit/CKIActivityStreamSubmissionItem.h>
#import <CanvasKit/CKIAssignment.h>
#import <CanvasKit/CKIAssignmentGroup.h>
#import <CanvasKit/CKIAttachment.h>
#import <CanvasKit/CKIBrand.h>
#import <CanvasKit/CKICalendarEvent.h>
#import <CanvasKit/CKIConversation.h>
#import <CanvasKit/CKIContext.h>
#import <CanvasKit/CKICourse.h>
#import <CanvasKit/CKIDiscussionTopic.h>
#import <CanvasKit/CKIDiscussionEntry.h>
#import <CanvasKit/CKIExternalTool.h>
#import <CanvasKit/CKIFavorite.h>
#import <CanvasKit/CKIFile.h>
#import <CanvasKit/CKIFolder.h>
#import <CanvasKit/CKIGroup.h>
#import <CanvasKit/CKIGroupCategory.h>
#import <CanvasKit/CKILockableModel.h>
#import <CanvasKit/CKILockInfo.h>
#import <CanvasKit/CKIModel.h>
#import <CanvasKit/CKIModule.h>
#import <CanvasKit/CKIModuleItem.h>
#import <CanvasKit/CKIOutcome.h>
#import <CanvasKit/CKIOutcomeGroup.h>
#import <CanvasKit/CKIOutcomeLink.h>
#import <CanvasKit/CKIPage.h>
#import <CanvasKit/CKIPoll.h>
#import <CanvasKit/CKIPollSubmission.h>
#import <CanvasKit/CKIPollSession.h>
#import <CanvasKit/CKIPollChoice.h>
#import <CanvasKit/CKIQuiz.h>
#import <CanvasKit/CKIRubric.h>
#import <CanvasKit/CKIRubricAssessment.h>
#import <CanvasKit/CKIRubricCriterion.h>
#import <CanvasKit/CKIRubricCriterionRating.h>
#import <CanvasKit/CKISection.h>
#import <CanvasKit/CKIService.h>
#import <CanvasKit/CKISubmission.h>
#import <CanvasKit/CKISubmissionComment.h>
#import <CanvasKit/CKISubmissionRecord.h>
#import <CanvasKit/CKIMediaComment.h>
#import <CanvasKit/CKITab.h>
#import <CanvasKit/CKITerm.h>
#import <CanvasKit/CKITodoItem.h>
#import <CanvasKit/CKIUser.h>
#import <CanvasKit/CKIEnrollment.h>
#import <CanvasKit/CKILiveAssessment.h>
#import <CanvasKit/CKILiveAssessmentResult.h>
#import <CanvasKit/CKIConversationMessage.h>
#import <CanvasKit/CKIConversationRecipient.h>
#import <CanvasKit/CKIPermissions.h>

#pragma mark - Networking

#import <CanvasKit/CKIClient.h>
#import <CanvasKit/CKIClient+CKIEnrollment.h>
#import <CanvasKit/CKIClient+CKIAccountDomain.h>
#import <CanvasKit/CKIClient+CKIActivityStreamItem.h>
#import <CanvasKit/CKIClient+CKIAssignment.h>
#import <CanvasKit/CKIClient+CKIAssignmentGroup.h>
#import <CanvasKit/CKIClient+CKICalendarEvent.h>
#import <CanvasKit/CKIClient+CKIConversation.h>
#import <CanvasKit/CKIClient+CKICourse.h>
#import <CanvasKit/CKIClient+CKIExternalTool.h>
#import <CanvasKit/CKIClient+CKIFavorite.h>
#import <CanvasKit/CKIClient+CKIFile.h>
#import <CanvasKit/CKIClient+CKIFolder.h>
#import <CanvasKit/CKIClient+CKIGroup.h>
#import <CanvasKit/CKIClient+CKIGroupCategory.h>
#import <CanvasKit/CKIClient+CKIModule.h>
#import <CanvasKit/CKIClient+CKIModel.h>
#import <CanvasKit/CKIClient+CKIModule.h>
#import <CanvasKit/CKIClient+CKIModuleItem.h>
#import <CanvasKit/CKIClient+CKIOutcome.h>
#import <CanvasKit/CKIClient+CKIOutcomeGroup.h>
#import <CanvasKit/CKIClient+CKIOutcomeLink.h>
#import <CanvasKit/CKIClient+CKIPage.h>
#import <CanvasKit/CKIClient+CKIPollSession.h>
#import <CanvasKit/CKIClient+CKIPoll.h>
#import <CanvasKit/CKIClient+CKIPollSubmission.h>
#import <CanvasKit/CKIClient+CKIPollChoice.h>
#import <CanvasKit/CKIClient+CKIPage.h>
#import <CanvasKit/CKIClient+CKIQuiz.h>
#import <CanvasKit/CKIClient+CKISection.h>
#import <CanvasKit/CKIClient+CKIService.h>
#import <CanvasKit/CKIClient+CKITab.h>
#import <CanvasKit/CKIClient+CKITodoItem.h>
#import <CanvasKit/CKIClient+CKISubmissionComment.h>
#import <CanvasKit/CKIClient+CKISubmissionRecord.h>
#import <CanvasKit/CKIClient+CKIUser.h>
#import <CanvasKit/CKIClient+CKIDiscussionTopic.h>
#import <CanvasKit/CKIClient+CKILiveAssessment.h>
#import <CanvasKit/CKIClient+CKILiveAssessmentResult.h>
#import <CanvasKit/NSValueTransformer+CKIPredefinedTransformerAdditions.h>

#import <CanvasKit/CKISubmission+TextEntrySubmissionHTMLFile.h>
#import <CanvasKit/CKISubmission+DiscussionSubmissionHTMLFile.h>

#pragma mark - Utilities

#import <CanvasKit/NSDictionary+DictionaryByAddingObjectsFromDictionary.h>
