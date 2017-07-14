// @flow

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'

export const QuizSubmissionActions = (api: typeof canvas): any => ({
  refreshQuizSubmissions: createAction('quiz-submissions.update', (courseID: string, quizID: string, assignmentID: string) => ({
    promise: api.getQuizSubmissions(courseID, quizID),
    quizID,
    assignmentID,
  })),
})

export default (QuizSubmissionActions(canvas): any)
