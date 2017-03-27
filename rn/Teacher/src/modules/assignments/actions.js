/* @flow */

import { createAction } from 'redux-actions'
import canvas from './../../api/canvas-api'
import type { AssignmentListActionProps } from './map-state-to-props'

export let AssignmentListActions: (canvas: typeof canvas) => AssignmentListActionProps = (api) => ({
  refreshAssignmentList: createAction('assignmentList.refresh', (courseID) => {
    return {
      promise: api.getCourseAssignmentGroups(courseID),
      courseID,
    }
  }),
})

export default (AssignmentListActions(canvas): AssignmentListActionProps)
