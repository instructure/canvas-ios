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

import { CourseModel } from '../canvas-api/model'
import template, { type Template } from '../utils/template'
import { section } from './section'

export const courseTerm: Template<CourseTerm> = template({
  id: '1',
  created_at: '2017-03-17T19:15:25Z',
  name: 'Default Term',
})

export const course: Template<Course> = template({
  id: '1',
  account_id: '1',
  name: 'Learn React Native',
  short_name: 'rn',
  course_code: 'rn 101',
  image_download_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
  is_favorite: true,
  default_view: 'wiki',
  enrollments: [{
    enrollment_state: 'active',
    role: 'TeacherEnrollment',
    role_id: '1',
    type: 'teacher',
    user_id: '1',
  }],
  permissions: {
    viewAnalytics: true,
    viewAllGrades: true,
  },
  workflow_state: 'available',
  term: {
    id: '1',
    created_at: '2018-02-08T23:13:39Z',
    end_at: '2030-02-08T23:13:39Z',
    start_at: '2018-02-08T23:13:39Z',
    name: 'Default Term',
    workflow_state: 'available',
  },
  end_at: '2030-02-08T23:13:39Z',
})

export const courseModel: Template<CourseModel> = overrides =>
  Object.assign(new CourseModel(course()), overrides)

export const courseWithSection: Template<Course> = function (defaults) {
  return course({
    ...defaults,
    sections: [section()],
  })
}

export const customColors: Template<CustomColors> = template({
  custom_colors: {
    course_1: '#fff',
  },
})
