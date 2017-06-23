// @flow

import { paginate, exhaust } from '../utils/pagination'

export function getGroupsForCourse (courseID: string): Promise<ApiResponse<Array<Group>>> {
  const groups = paginate(`courses/${courseID}/groups`, {
    params: { include: ['users'] },
  })
  return exhaust(groups)
}
