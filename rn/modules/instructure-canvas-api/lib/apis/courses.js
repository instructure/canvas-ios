//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

/* @flow */

import { paginate, exhaust } from '../utils/pagination'
import httpClient from '../httpClient'

export function getCourses (): Promise<ApiResponse<Course[]>> {
  const courses = paginate('courses', {
    params: {
      include: ['term', 'favorites', 'course_image', 'sections'],
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

export function getCourseGradingPeriods (courseID: string): Promise<ApiResponse<GradingPeriodResponse>> {
  const url = `courses/${courseID}/grading_periods`
  return httpClient().get(url)
}

export function getCourseSections (courseID: string): Promise<ApiResponse<Section[]>> {
  const url = `courses/${courseID}/sections`
  const options = {
    params: {
      include: ['total_students'],
    },
  }
  return httpClient().get(url, options)
}

export function getCourseUsers (courseID: string, enrollmentType?: string = '', userIDs: Array<string>): Promise<ApiResponse<User[]>> {
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

export function favoriteCourse (courseID: string): Promise<AxiosResponse<Favorite>> {
  return httpClient().post(`users/self/favorites/courses/${courseID}`)
}

export function unfavoriteCourse (courseID: string): Promise<AxiosResponse<Favorite>> {
  return httpClient().delete(`users/self/favorites/courses/${courseID}`)
}

export function updateCourseColor (courseId: string, hexcode: string): Promise<AxiosResponse<UpdateCustomColorResponse>> {
  return httpClient().put(`users/self/colors/course_${courseId}`, { hexcode })
}

export function createCourse (course: CreateCourse): Promise<AxiosResponse<Course>> {
  return httpClient().post(`accounts/self/courses`, course)
}
