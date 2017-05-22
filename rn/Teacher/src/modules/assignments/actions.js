/* @flow */

import { createAction } from 'redux-actions'
import canvas from './../../api/canvas-api'
import type { AssignmentListActionProps } from './map-state-to-props'

export let AssignmentListActions: (typeof canvas) => AssignmentListActionProps = (api) => ({
  refreshAssignmentList: createAction('assignmentList.refresh', (courseID: string, gradingPeriodID?: string) => {
    const include = ['assignments', 'all_dates', 'overrides']
    return {
      promise: api.getAssignmentGroups(courseID, gradingPeriodID, include),
      courseID,
      gradingPeriodID,
    }
  }),
  refreshAssignment: createAction('assignment.refresh', (courseID: string, assignmentID: string) => {
    return {
      promise: api.getAssignment(courseID, assignmentID),
      courseID,
      assignmentID,
    }
  }),
  updateAssignment: createAction('assignment.update', (courseID, updatedAssignment, originalAssignment) => {
    return {
      promise: api.updateAssignment(courseID, updatedAssignment),
      courseID,
      updatedAssignment,
      originalAssignment,
      handlesError: true,
    }
  }),
  cancelAssignmentUpdate: createAction('assignment.cancel-update', (originalAssignment) => {
    return { originalAssignment }
  }),
})

export default (AssignmentListActions(canvas): AssignmentListActionProps)
