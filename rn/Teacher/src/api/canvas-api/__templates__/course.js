/* @flow */

import template, { type Template } from '../../../utils/template'

export const course: Template<Course> = template({
  id: '1',
  name: 'Learn React Native',
  short_name: 'rn',
  course_code: 'rn 101',
  image_download_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
  is_favorite: true,
  default_view: 'wiki',
  term: { name: 'Default Term' },
})

export const customColors: Template<CustomColors> = template({
  custom_colors: {
    course_1: '#fff',
  },
})
