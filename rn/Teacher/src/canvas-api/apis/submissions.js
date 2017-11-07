//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// @flow

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getSubmissions (courseID: string, assignmentID: string, grouped: boolean = false): Promise<ApiResponse<Array<SubmissionWithHistory>>> {
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

export function gradeSubmission (courseID: string, assignmentID: string, userID: string, submissionParams: SubmissionGradeParams): Promise<ApiResponse<Submission>> {
  return httpClient().put(`/courses/${courseID}/assignments/${assignmentID}/submissions/${userID}`, {
    submission: submissionParams,
  })
}

export function gradeSubmissionWithRubric (courseID: string, assignmentID: string, userID: string, rubricParams: { [string]: RubricAssessment }): Promise<ApiResponse<Submission>> {
  return httpClient().put(`/courses/${courseID}/assignments/${assignmentID}/submissions/${userID}`, {
    rubric_assessment: rubricParams,
  })
}

export function commentOnSubmission (courseID: string, assignmentID: string, userID: string, comment: SubmissionCommentParams): Promise<ApiResponse<any>> {
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

export function refreshSubmissionSummary (courseID: string, assignmentID: string): Promise<ApiResponse<Submission>> {
  return httpClient().get(`/courses/${courseID}/assignments/${assignmentID}/submission_summary`)
}

export function getSubmissionsForUsers (courseID: string, userIDs: string[]): Promise<ApiResponse<Submission[]>> {
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

