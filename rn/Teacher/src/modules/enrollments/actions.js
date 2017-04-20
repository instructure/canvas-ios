// @flow

import { createAction } from 'redux-actions'
import canvas from '../../api/canvas-api'
import type { EnrollmentsActionProps } from './enrollments-prop-types'

export const EnrollmentsActions = (api: typeof canvas): EnrollmentsActionProps => ({
  refreshEnrollments: createAction('enrollments.update', (courseID: string) => ({
    promise: api.getCourseEnrollments(courseID),
    courseID,
  })),
})

export default (EnrollmentsActions(canvas): EnrollmentsActionProps)
