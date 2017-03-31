// @flow

import { createAction } from 'redux-actions'
import canvas from './../../api/canvas-api'
import type { CourseListActionProps } from './course-prop-types'

export let CoursesActions = (api: typeof canvas): CourseListActionProps => ({
  refreshCourses: createAction('courses.refresh', () => Promise.all([
    api.getCourses(),
    api.getCustomColors(),
  ])),
  updateCourseColor: createAction('courses.updateColor', (courseID: string, color: string) => {
    return {
      courseID,
      color,
      promise: api.updateCourseColor(courseID, color),
    }
  }),
  refreshGradingPeriods: createAction('courses.refreshGradingPeriods', (courseID: number) => {
    return {
      promise: api.getCourseGradingPeriods(courseID),
      handlesError: true,
    }
  }),
})

export default (CoursesActions(canvas): CourseListActionProps)
