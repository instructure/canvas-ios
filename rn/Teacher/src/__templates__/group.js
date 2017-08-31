// @flow

import template, { type Template } from '../utils/template'
import { user } from './users'

export const group: Template<Group> = template({
  name: 'Red Squadron',
  id: '1',
  group_category_id: '5531',
  users: [user()],
  members_count: 23432343,
})
