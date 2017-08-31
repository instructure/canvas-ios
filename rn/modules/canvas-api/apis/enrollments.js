// @flow

import { paginate, exhaust } from '../utils/pagination'

export function getCourseEnrollments (courseID: string): Promise<ApiResponse<Array<Enrollment>>> {
  const enrollments = paginate(`courses/${courseID}/enrollments`, {
    params: {
      include: ['avatar_url'],
    },
  })

  return exhaust(enrollments)
}
