/* @flow */

import template from '../../utils/template'

export const course: Template<Course> = template({
  id: 1,
  name: 'Learn React Native',
  short_name: 'rn',
  course_code: 'rn 101',
  image_download_url: 'https://farm3.staticflickr.com/2926/14690771011_945f91045a.jpg',
  is_favorite: true,
})

export const customColors: Template<Course> = template({
  custom_colors: {
    course_1: '#fff',
  },
})
