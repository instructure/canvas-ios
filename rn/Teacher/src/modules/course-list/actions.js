// @flow

import { createAction } from 'redux-actions'
import canvas from './../../api/canvas-api'
import type { CoursesActionProps } from './props'

export let CoursesActions = (api: typeof canvas): CoursesActionProps => ({
  refreshCourses: createAction('courses.refresh', () => Promise.all([
    api.getCourses(),
    api.getCustomColors(),
  ])),
})

export default (CoursesActions(canvas): CoursesActionProps)
