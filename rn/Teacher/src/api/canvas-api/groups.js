/* @flow */

import { paginate, exhaust } from '../utils/pagination'

export function getUserGroups (): Promise<ApiResponse<Group[]>> {
  const groups = paginate('users/self/groups', {
    params: {
      include: ['tabs'],
    },
  })
  return exhaust(groups)
}
