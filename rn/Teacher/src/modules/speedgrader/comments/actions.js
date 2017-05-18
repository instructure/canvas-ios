// @flow

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'
import uuid from 'uuid/v1'

export type CommentActions = {
  makeAComment: (
    courseID: string,
    assignmentID: string,
    userID: string,
    comment: SubmissionCommentParams) => void,
}

export const SubmissionCommentActions = (api: typeof canvas): CommentActions => ({
  makeAComment: createAction('submissions.comments.send', (courseID: string, assignmentID: string, userID: string, comment: SubmissionCommentParams) => ({
    comment,
    assignmentID,
    userID,
    localID: uuid(),
    timestamp: new Date().toISOString(),
    promise: api.commentOnSubmission(
      courseID, assignmentID, userID, comment
    ),
  })),
})

export default (SubmissionCommentActions(canvas): CommentActions)
