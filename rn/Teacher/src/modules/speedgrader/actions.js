// @flow

import { createAction } from 'redux-actions'
import canvas from '../../api/canvas-api'

export type SpeedGraderActionsType = {
  excuseAssignment: (courseID: string, assignmentID: string, userID: string, submissionID: ?string) => any,
  selectSubmissionFromHistory: (submissionID: string, index: number) => any,
  gradeSubmission: (courseID: string, assignmentID: string, userID: string, submissionID: ?string, grade: string) => any,
}

export const SpeedGraderActions = (api: typeof canvas): SpeedGraderActionsType => ({
  excuseAssignment: createAction('submission.excuse', (courseID: string, assignmentID: string, userID: string, submissionID: ?string) => ({
    promise: api.gradeSubmission(courseID, assignmentID, userID, {
      excuse: true,
    }),
    submissionID,
    assignmentID,
  })),
  selectSubmissionFromHistory: createAction('submission.selectFromHistory', (submissionID: string, index: number) => ({
    submissionID,
    index,
  })),
  gradeSubmission: createAction('submission.grade', (courseID: string, assignmentID: string, userID: string, submissionID: ?string, grade: string) => ({
    promise: api.gradeSubmission(courseID, assignmentID, userID, {
      posted_grade: grade,
    }),
    submissionID,
    assignmentID,
  })),
})

export default (SpeedGraderActions(canvas): SpeedGraderActionsType)
