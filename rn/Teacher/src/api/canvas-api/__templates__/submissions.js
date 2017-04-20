// @flow

import template, { type Template } from '../../../utils/template'
import { user } from './users'

export const submission: Template<Submission> = template({
  id: '32',
  user: user({ id: '55' }),
  user_id: '55',
  grade: 'B-',
  submitted_at: '2017-04-05T15:12:45Z',
  excused: false,
  late: false,
  workflow_state: 'submitted',
})

export function submissionHistory (submissionOverrides: Array<Object> = [submission()], commentOverrides: Array<Object> = []): SubmissionHistory {
  const submissionHistory = submissionOverrides.map(submission)

  const comments = [] // TODO: commentOverrides.map(submissionComment)

  return {
    ...submissionHistory[0],
    submission_history: submissionHistory,
    submission_comments: comments,
  }
}
