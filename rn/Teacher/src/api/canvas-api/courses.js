/* @flow */

import type { ApiResponse } from '../response'
import { paginate } from '../utils/paginate'

export function getCourses (): Promise<ApiResponse<Course[]>> {
  return paginate('courses')
}
