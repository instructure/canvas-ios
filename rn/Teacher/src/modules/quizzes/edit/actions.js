/* @flow */

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export let Actions = (api: CanvasApi): * => ({
  updateQuiz: createAction('quizzes.edit.update', (updatedQuiz: Quiz, courseID: string, originalQuiz: Quiz) => {
    return {
      promise: api.updateQuiz(updatedQuiz, courseID),
      updatedQuiz,
      originalQuiz,
      handlesError: true,
    }
  }),
})

export default (Actions(canvas): *)
