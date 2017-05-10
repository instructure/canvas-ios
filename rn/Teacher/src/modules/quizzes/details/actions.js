/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'

export let Actions: (typeof canvas) => any = (api) => ({
  refreshQuiz: createAction('quizDetails.refresh', (courseID: string, quizID: string) => {
    return {
      promise: api.getQuiz(courseID, quizID),
      courseID,
      quizID,
    }
  }),
})

export default (Actions(canvas): any)
