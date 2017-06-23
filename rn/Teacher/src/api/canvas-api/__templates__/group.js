// @flow

import template, { type Template } from '../../../utils/template'
import { user } from './users'

export const group: Template<Assignment> = template({
  name: 'Red Squadron',
  id: '1',
  group_category_id: '5531',
  users: [user()],
})
