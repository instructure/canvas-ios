/* @flow */

import { createAction } from 'redux-actions'
import * as assignmentsApi from './../../api/canvas-api/assignments'
import type { AssignmentDetailsActionProps } from './props'

export let AssignmentDetailsActions: (CoursesApi: typeof assignmentsApi) => AssignmentDetailsActionProps = (api) => ({
  refreshAssignmentDetails: createAction('assignmentDetails.refresh', api.getAssignmentDetails),
})

export default (AssignmentDetailsActions(assignmentsApi): AssignmentDetailsActionProps)
