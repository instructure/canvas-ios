// @flow

import { createAction } from 'redux-actions'
import canvas from '../../api/canvas-api'
import type { EnrollmentsActionProps } from './enrollments-prop-types'

export let EnrollmentsActions = (api: typeof canvas): EnrollmentsActionProps => ({
  refreshEnrollments: createAction('submissions.update', (courseID: string) => {
    return {
      promise: canvas.getCourseEnrollments(courseID),
      courseID,
    }
  }),
})

export default (EnrollmentsActions(canvas): EnrollmentsActionProps)
