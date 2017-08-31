// @flow

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export const QuizSubmissionActions = (api: CanvasApi): * => ({
  refreshQuizSubmissions: createAction('quiz-submissions.update', (courseID: string, quizID: string, assignmentID: string) => ({
    promise: api.getQuizSubmissions(courseID, quizID),
    quizID,
    assignmentID,
  })),
})

export default (QuizSubmissionActions(canvas): *)
