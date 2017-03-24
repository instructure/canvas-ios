/* @flow */

import { paginate, exhaust } from '../utils/pagination'
import httpClient from './httpClient'

export function getCourses (): Promise<ApiResponse<Course[]>> {
  const courses = paginate('courses', {
    params: {
      include: ['favorites', 'course_image'],
    },
  })
  return exhaust(courses)
}

export function getCourseTabs (courseID: string): Promise<ApiResponse<Tab[]>> {
  const tabs = paginate(`courses/${courseID}/tabs`, {
    per_page: 99,
  })
  return exhaust(tabs)
}

export function getCourseAssignments (courseID: number): Promise<ApiResponse<Assignment[]>> {
  const url = `courses/${courseID}/assignments`
  return httpClient().get(url)
}

export function getCourseAssignmentGroups (courseID: number): Promise<ApiResponse<AssignmentGroup[]>> {
  const url = `courses/${courseID}/assignment_groups`
  return paginate(url, {
    params: {
      include: ['assignments'],
      per_page: 2,
    },
  })
}

export function favoriteCourse (courseID: string): Promise<AxiosResponse<Favorite>> {
  return httpClient().post(`users/self/favorites/courses/${courseID}`)
}

export function unfavoriteCourse (courseID: string): Promise<AxiosResponse<Favorite>> {
  return httpClient().delete(`users/self/favorites/courses/${courseID}`)
}

export function updateCourseColor (courseId: string, hexcode: string): Promise<AxiosResponse<UpdateCustomColorResponse>> {
  return httpClient().put(`users/self/colors/course_${courseId}`, { hexcode })
}
