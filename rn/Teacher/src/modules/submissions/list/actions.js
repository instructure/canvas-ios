// @flow

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export let Actions = (api: CanvasApi): * => ({
  refreshSubmissionSummary: createAction('submissions.summary', (courseID: string, assignmentID: string) => ({
    promise: api.refreshSubmissionSummary(courseID, assignmentID),
    courseID,
    assignmentID,
  })),
  refreshSubmissions: createAction('submissions.update', (courseID: string, assignmentID: string, grouped: boolean = false) => ({
    promise: api.getSubmissions(courseID, assignmentID, grouped),
    assignmentID,
  })),
  getUserSubmissions: createAction('submissions.user', (courseID: string, userID: string) => ({
    promise: api.getSubmissionsForUsers(courseID, [userID]),
  })),
})

export default (Actions(canvas): any)
