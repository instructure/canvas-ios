//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

/* @flow */

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getCourses (): Promise<ApiResponse<Course[]>> {
  const courses = paginate('courses', {
    params: {
      include: ['term', 'favorites', 'course_image', 'sections', 'total_scores', 'current_grading_period_scores'],
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

export function getCourse (courseID: string): Promise<ApiResponse<Course>> {
  return httpClient().get(`/courses/${courseID}`, {
    params: {
      include: ['term', 'favorites', 'course_image', 'sections'],
    },
  })
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

export function getCourseGradingPeriods (courseID: string): Promise<ApiResponse<GradingPeriodResponse>> {
  const url = `courses/${courseID}/grading_periods`
  return httpClient().get(url)
}

export function getCourseSections (courseID: string): Promise<ApiResponse<Section[]>> {
  const sections = paginate(`courses/${courseID}/sections`, {
    params: {
      include: ['total_students'],
      per_page: 99,
    },
  })
  return exhaust(sections)
}

export function getCourseUsers (courseID: string, enrollmentType?: string = '', userIDs?: string[]): Promise<ApiResponse<User[]>> {
  const url = `courses/${courseID}/users`
  const params = {}
  if (enrollmentType) {
    params.enrollment_type = [enrollmentType]
  }
  if (userIDs) {
    params.user_ids = userIDs
  }
  const options = { params }
  return httpClient().get(url, options)
}

export function favoriteCourse (courseID: string): Promise<ApiResponse<Favorite>> {
  return httpClient().post(`users/self/favorites/courses/${courseID}`)
}

export function unfavoriteCourse (courseID: string): Promise<ApiResponse<Favorite>> {
  return httpClient().delete(`users/self/favorites/courses/${courseID}`)
}

export function updateCourseColor (courseID: string, hexcode: string): Promise<ApiResponse<UpdateCustomColorResponse>> {
  return httpClient().put(`users/self/colors/course_${courseID}`, { hexcode })
}

export function createCourse (course: CreateCourse): Promise<ApiResponse<Course>> {
  return httpClient().post(`accounts/self/courses`, course)
}

export function getCourseEnabledFeatures (courseID: string): Promise<ApiResponse<[string]>> {
  let features = paginate(`/courses/${courseID}/features/enabled`, {
    per_page: 99,
  })
  return exhaust(features)
}

export function getCourseLicenses (courseID: string): Promise<ApiResponse<License[]>> {
  const licenses = paginate(`courses/${courseID}/content_licenses`, { params: { per_page: 99 } })
  return exhaust(licenses)
}

export function getCoursePermissions (courseID: string): Promise<ApiResponse<{ [string]: boolean }>> {
  return httpClient().get(`courses/${courseID}/permissions`)
}
