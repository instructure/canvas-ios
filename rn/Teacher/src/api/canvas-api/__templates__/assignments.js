/* @flow */

import template from '../../../utils/template'

export const assignment: Template<Assignment> = template({
  id: 123456789,
  name: 'learn to write code',
})

export const assignmentGroup: Template<AssignmentGroup> = template({
  id: 1,
  name: 'Learn React Native',
  assignments: [
    {
      id: 123455432,
      name: 'Assignments',
    },
  ],
})
