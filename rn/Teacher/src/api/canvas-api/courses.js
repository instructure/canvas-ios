/* @flow */

import { paginate } from '../utils/paginate'

export function getCourses (): Promise<ApiResponse<Course[]>> {
  return paginate('courses', {
    params: {
      include: ['favorites', 'course_image'],
    },
  })
}
