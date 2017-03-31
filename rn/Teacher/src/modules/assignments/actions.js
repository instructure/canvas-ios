/* @flow */

import { createAction } from 'redux-actions'
import canvas from './../../api/canvas-api'
import type { AssignmentListActionProps } from './map-state-to-props'

export let AssignmentListActions: (typeof canvas) => AssignmentListActionProps = (api) => ({
  refreshAssignmentList: createAction('assignmentList.refresh', (courseID: number, gradingPeriodID?: number) => {
    return {
      promise: api.getCourseAssignmentGroups(courseID, gradingPeriodID),
      courseID,
      gradingPeriodID,
    }
  }),
})

export default (AssignmentListActions(canvas): AssignmentListActionProps)
