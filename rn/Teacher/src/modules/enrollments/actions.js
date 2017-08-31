// @flow

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export const EnrollmentsActions = (api: CanvasApi): * => ({
  refreshEnrollments: createAction('enrollments.update', (courseID: string) => ({
    promise: api.getCourseEnrollments(courseID),
    courseID,
  })),
})

export default (EnrollmentsActions(canvas): *)
