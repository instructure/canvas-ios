/* @flow */

import template, { type Template } from '../utils/template'
import { user } from './users'
import { quiz } from './quiz'

export const quizSubmission: Template<Submission> = template({
  id: '32',
  quiz_id: quiz().id,
  user_id: user().id,
  finished_at: '2017-04-05T15:12:45Z',
  kept_score: 5,
  workflow_state: 'complete',
})
