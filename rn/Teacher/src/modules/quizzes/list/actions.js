/* @flow */

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'
import { UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION } from '../../courses/actions'

export let Actions = (api: CanvasApi): * => ({
  refreshQuizzes: createAction('quizzesList.refresh', (courseID: string) => {
    return {
      promise: api.getQuizzes(courseID),
      courseID,
    }
  }),
  updateCourseDetailsSelectedTabSelectedRow: createAction(UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION, (rowID: string) => {
    return { rowID }
  }),
})

export default (Actions(canvas): *)
