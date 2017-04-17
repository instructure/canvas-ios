// @flow

import template from '../../../utils/template'
import { type Assignee } from '../map-state-to-props'

export const enrollmentAssignee: Template<Assignee> = template({
  id: 'student-1234',
  dataId: '1234',
  type: 'student',
  name: 'Bill Murray',
  info: 'john@schimdt.com',
  imageURL: 'http://www.fillmurray.com/100/100',
})

export const sectionAssignee: Template<Assignee> = template({
  id: 'section-1234',
  dataId: '1234',
  type: 'section',
  name: 'Section 1',
  info: '9834 students',
})

export const groupAssignee: Template<Assignee> = template({
  id: 'group-1234',
  dataId: '1234',
  type: 'group',
  name: 'Horrible Students',
  info: '889334 students',
})

export const everyoneAssignee: Template<Assignee> = template({
  id: 'everyone',
  dataId: 'everyone',
  type: 'everyone',
  name: 'Everyone',
})
