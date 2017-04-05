// @flow

import { paginate, exhaust } from '../utils/pagination'

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
