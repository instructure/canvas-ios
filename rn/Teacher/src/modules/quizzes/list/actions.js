/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'

export let Actions: (typeof canvas) => any = (api) => ({
  refreshQuizzes: createAction('quizzesList.refresh', (courseID: string) => {
    return {
      promise: api.getQuizzes(courseID),
      courseID,
    }
  }),
})

export default (Actions(canvas): any)
