/* @flow */

import { paginate } from '../utils/paginate'
import httpClient from './httpClient'

export function getCourses (): Promise<ApiResponse<Course[]>> {
  return paginate('courses', {
    params: {
      include: ['favorites', 'course_image'],
    },
  })
}

export function getCourseTabs (courseID: number): Promise<ApiResponse<Tab[]>> {
  const url = `courses/${courseID}/tabs`
  return httpClient().get(url)
}
