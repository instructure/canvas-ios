/* @flow */

import { createAction } from 'redux-actions'
import canvas from './../../api/canvas-api'
import type { AssignmentListActionProps } from './props'

export let AssignmentListActions: (canvas: typeof canvas) => AssignmentListActionProps = (api) => ({
  refreshAssignmentList: createAction('assignmentList.refresh', api.getCourseAssignmentGroups),
})

export default (AssignmentListActions(canvas): AssignmentListActionProps)
