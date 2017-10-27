// @flow

import template, { type Template } from '../utils/template'

export const page: Template<Page> = template({
  url: 'page-1',
  title: 'Page 1',
  created_at: '2017-03-17T19:15:25Z',
  updated_at: '2017-03-17T19:15:25Z',
  hide_from_students: false,
  editing_roles: 'teachers',
  body: '<p>Hello, World!</p>',
  published: true,
  front_page: false,
})
