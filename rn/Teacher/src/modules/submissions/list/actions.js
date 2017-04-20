// @flow

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'
import type { SubmissionListActionProps } from './submission-prop-types'

export const SubmissionActions = (api: typeof canvas): SubmissionListActionProps => ({
  refreshSubmissions: createAction('submissions.update', (courseID: string, assignmentID: string) => ({
    promise: api.getSubmissions(courseID, assignmentID),
    assignmentID,
  })),
})

export default (SubmissionActions(canvas): SubmissionListActionProps)
