/* @flow */

import { createAction } from 'redux-actions'
import canvas from '../../../api/canvas-api'
import { UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION } from '../../courses/actions'

export let Actions: (typeof canvas) => any = (api) => ({
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

export default (Actions(canvas): any)
