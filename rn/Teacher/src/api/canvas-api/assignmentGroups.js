/* @flow */

import { paginate, exhaust } from '../utils/pagination'

export function getAssignmentGroups (courseID: string, gradingPeriodID?: string, include?: string[]): Promise<ApiResponse<AssignmentGroup[]>> {
  const url = `courses/${courseID}/assignment_groups`
  let options = {
    params: {
      include: include,
      per_page: 99,
      grading_period_id: gradingPeriodID,
    },
  }

  const groups = paginate(url, options)

  return exhaust(groups)
}
