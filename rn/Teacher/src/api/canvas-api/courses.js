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

export function updateCourse (course: Course): Promise<ApiResponse<Course>> {
  const safeParams = {
    name: course.name,
    default_view: course.default_view,
  }
  return httpClient().put(`/courses/${course.id}`, { course: safeParams })
}

export function getCourseAssignments (courseID: string): Promise<ApiResponse<Assignment[]>> {
  const url = `courses/${courseID}/assignments`
  return httpClient().get(url)
}

// Exhausting pagination here because it's easier. I am not a horrible person
export function getCourseAssignmentGroups (courseID: string, gradingPeriodID?: string): Promise<ApiResponse<AssignmentGroup[]>> {
  const url = `courses/${courseID}/assignment_groups`
  let options = {
    params: {
      include: ['assignments', 'all_dates', 'overrides'],
      per_page: 99,
      grading_period_id: gradingPeriodID,
    },
  }

  const groups = paginate(url, options)

  return exhaust(groups)
}

export function getCourseGradingPeriods (courseID: string): Promise<ApiResponse<GradingPeriodResponse>> {
  const url = `courses/${courseID}/grading_periods`
  return httpClient().get(url)
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
