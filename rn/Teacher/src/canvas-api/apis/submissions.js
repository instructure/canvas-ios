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

// @flow

import i18n from 'format-message'
import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getSubmissions (courseID: string, assignmentID: string, grouped: boolean = false): ApiPromise<SubmissionWithHistory[]> {
  const submissions = paginate(`courses/${courseID}/assignments/${assignmentID}/submissions`, {
    params: {
      include: [
        'submission_history',
        'submission_comments',
        'rubric_assessment',
        'total_scores',
        'user',
        'group',
      ],
      grouped,
    },
  })

  return exhaust(submissions)
}

type SubmissionGradeParams = {
  excuse?: boolean,
  posted_grade?: string,
}

export function gradeSubmission (courseID: string, assignmentID: string, userID: string, submissionParams: SubmissionGradeParams): ApiPromise<Submission> {
  return httpClient.put(`/courses/${courseID}/assignments/${assignmentID}/submissions/${userID}`, {
    submission: submissionParams,
  })
}

export function gradeSubmissionWithRubric (courseID: string, assignmentID: string, userID: string, rubricParams: { [string]: RubricAssessment }): ApiPromise<Submission> {
  return httpClient.put(`/courses/${courseID}/assignments/${assignmentID}/submissions/${userID}`, {
    rubric_assessment: rubricParams,
  })
}

export function commentOnSubmission (courseID: string, assignmentID: string, userID: string, comment: SubmissionCommentParams): ApiPromise<any> {
  const data = { comment: {} }
  switch (comment.type) {
    case 'text':
      data.comment.text_comment = comment.comment
      break
    case 'media':
      if (comment.groupComment) {
        // FIXME: Remove this text_comment when the api honors the group flag for media-only comments.
        data.comment.text_comment = i18n('This is a media comment')
      }
      data.comment.media_comment_type = comment.mediaType
      data.comment.media_comment_id = comment.mediaID
      break
  }

  if (comment.groupComment) {
    data.comment.group_comment = true
  }

  return httpClient.put(`/courses/${courseID}/assignments/${assignmentID}/submissions/${userID}`, data)
}

export function refreshSubmissionSummary (courseID: string, assignmentID: string): ApiPromise<Submission> {
  return httpClient.get(`/courses/${courseID}/assignments/${assignmentID}/submission_summary`)
}

export function getSubmissionsForUsers (courseID: string, userIDs: string[]): ApiPromise<Submission[]> {
  const submissions = paginate(`/courses/${courseID}/students/submissions`, {
    params: {
      student_ids: userIDs,
      include: [
        'submission_history',
        'submission_comments',
        'rubric_assessment',
        'total_scores',
        'user',
        'group',
      ],
    },
  })

  return exhaust(submissions)
}
