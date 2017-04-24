// @flow

import { createAction } from 'redux-actions'
import canvas from '../../api/canvas-api'

export type SpeedgraderActionsType = {
  excuseAssignment: (courseID: string, assignmentID: string, userID: string, submissionID: string) => any,
}

export const SpeedgraderActions = (api: typeof canvas): SpeedgraderActionsType => ({
  excuseAssignment: createAction('submission.excuse', (courseID: string, assignmentID: string, userID: string, submissionID: string) => ({
    promise: api.gradeSubmission(courseID, assignmentID, userID, {
      excuse: true,
    }),
    submissionID,
  })),
})

export default (SpeedgraderActions(canvas): SpeedgraderActionsType)
