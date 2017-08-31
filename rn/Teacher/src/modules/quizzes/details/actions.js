/* @flow */

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export let Actions = (api: CanvasApi): * => ({
  refreshQuiz: createAction('quizDetails.refresh', (courseID: string, quizID: string) => {
    return {
      promise: Promise.all([
        api.getQuiz(courseID, quizID),
        api.getAssignmentGroups(courseID),
      ]).then(([quiz, assignmentGroup]) => {
        if (quiz.data.assignment_id) {
          return Promise.all([
            Promise.resolve(quiz),
            Promise.resolve(assignmentGroup),
            api.getAssignment(courseID, quiz.data.assignment_id),
          ])
        }
        return Promise.resolve([quiz, assignmentGroup])
      }),
      courseID,
      quizID,
    }
  }),
})

export default (Actions(canvas): *)
