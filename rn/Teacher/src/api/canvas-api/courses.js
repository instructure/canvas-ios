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

export function favoriteCourse (courseId: string): Promise<AxiosResponse<Favorite>> {
  return httpClient().post(`users/self/favorites/courses/${courseId}`)
}

export function unfavoriteCourse (courseId: string): Promise<AxiosResponse<Favorite>> {
  return httpClient().delete(`users/self/favorites/courses/${courseId}`)
}
