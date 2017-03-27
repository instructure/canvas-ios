/* @flow */

import template from '../../../utils/template'

export const assignment: Template<Assignment> = template({
  id: 123456789,
  name: 'learn to write code',
  needs_grading_count: 0,
})

export const assignmentGroup: Template<AssignmentGroup> = template({
  id: 1,
  name: 'Learn React Native',
  position: 1,
  assignments: [
    {
      id: 123455432,
      name: 'Assignments',
    },
  ],
})
