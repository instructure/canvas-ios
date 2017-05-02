// @flow

import { paginate, exhaust } from '../utils/pagination'
import httpClient from './httpClient'

export function getSubmissions (courseID: string, assignmentID: string): Promise<ApiResponse<Array<SubmissionWithHistory>>> {
  const submissions = paginate(`courses/${courseID}/assignments/${assignmentID}/submissions`, {
    params: { include: [
      'submission_history',
      'submission_comments',
      'rubric_assessment',
      'total_scores',
    ] },
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
