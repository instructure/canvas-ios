/* @flow */

import template, { type Template } from '../utils/template'
import { section } from './section'

export const course: Template<Course> = template({
  id: '1',
  name: 'Learn React Native',
  short_name: 'rn',
  course_code: 'rn 101',
  image_download_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
  is_favorite: true,
  default_view: 'wiki',
  term: { name: 'Default Term' },
  enrollments: [{
    enrollment_state: 'active',
    role: 'TeacherEnrollment',
    role_id: '1',
    type: 'teacher',
    user_id: '1',
  }],
})

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
