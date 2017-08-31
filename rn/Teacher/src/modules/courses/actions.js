// @flow

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export const UPDATE_COURSE_DETAILS_SELECTED_TAB_SELECTED_ROW_ACTION: string = 'course-details.selected-tab.selected-row'

export let CoursesActions = (api: CanvasApi): * => ({
  refreshCourses: createAction('courses.refresh', () => ({
    promise: Promise.all([
      api.getCourses(),
      api.getCustomColors(),
    ]),
  })),
  updateCourseColor: createAction('courses.updateColor', (courseID: string, color: string) => {
    return {
      courseID,
      color,
      promise: api.updateCourseColor(courseID, color),
    }
  }),
  refreshGradingPeriods: createAction('courses.refreshGradingPeriods', (courseID: string) => {
    return {
      promise: api.getCourseGradingPeriods(courseID),
      handlesError: true,
    }
  }),
})

export default (CoursesActions(canvas): *)
