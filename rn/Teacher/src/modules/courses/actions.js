// @flow

import { createAction } from 'redux-actions'
import canvas from './../../api/canvas-api'
import type { CourseListActionProps } from './course-prop-types'

export let CoursesActions = (api: typeof canvas): CourseListActionProps => ({
  refreshCourses: createAction('courses.refresh', () => Promise.all([
    api.getCourses(),
    api.getCustomColors(),
  ])),
})

export default (CoursesActions(canvas): CourseListActionProps)
