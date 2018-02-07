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

// @flow

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
  return httpClient().put(`/courses/${courseID}/assignments/${assignmentID}/submissions/${userID}`, {
    submission: submissionParams,
  })
}

export function gradeSubmissionWithRubric (courseID: string, assignmentID: string, userID: string, rubricParams: { [string]: RubricAssessment }): ApiPromise<Submission> {
  return httpClient().put(`/courses/${courseID}/assignments/${assignmentID}/submissions/${userID}`, {
    rubric_assessment: rubricParams,
  })
}

export function commentOnSubmission (courseID: string, assignmentID: string, userID: string, comment: SubmissionCommentParams): ApiPromise<any> {
  const data = { comment: {} }
  switch (comment.type) {
    case 'text':
      data.comment.text_comment = comment.message
      break
    case 'media':
      data.comment.media_comment_type = comment.mediaType
      data.comment.media_comment_id = comment.mediaID
      break
  }

  if (comment.groupComment) {
    data.comment.group_comment = true
  }

  return httpClient().put(`/courses/${courseID}/assignments/${assignmentID}/submissions/${userID}`, data)
}

export function refreshSubmissionSummary (courseID: string, assignmentID: string): ApiPromise<Submission> {
  return httpClient().get(`/courses/${courseID}/assignments/${assignmentID}/submission_summary`)
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
