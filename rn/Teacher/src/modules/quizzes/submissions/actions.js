// @flow

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'

export const QuizSubmissionActions = (api: typeof canvas): any => ({
  refreshQuizSubmissions: createAction('quiz-submissions.update', (courseID: string, quizID: string) => ({
    promise: api.getQuizSubmissions(courseID, quizID),
    quizID,
  })),
})

export default (QuizSubmissionActions(canvas): any)
