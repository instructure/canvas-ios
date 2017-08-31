/* @flow */

import template, { type Template } from '../utils/template'

export const user: Template<User> = template({
  id: '1',
  name: 'Donald Trump',
  short_name: 'The Donald',
  sortable_name: 'Mr. President',
  bio: 'my bio is yuuuuuuuge',
  avatar_url: 'http://www.fillmurray.com/100/100',
})

export const userDisplay: Template<UserDisplay> = template({
  id: '1',
  short_name: 'The Donald',
  display_name: 'The Donald',
  avatar_url: 'http://www.fillmurray.com/100/100',
})
