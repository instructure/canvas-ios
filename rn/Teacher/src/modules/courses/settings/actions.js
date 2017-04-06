// @flow

import { createAction } from 'redux-actions'
import type { CourseSettingsActionProps } from './map-state-to-props'
import canvas from '../../../api/canvas-api'

export let CourseSettingsActions = (api: typeof canvas): CourseSettingsActionProps => ({
  updateCourse: createAction('courses.settings.update', (course: Course, oldCourse: Course) => ({
    course,
    oldCourse,
    courseID: course.id,
    promise: api.updateCourse(course),
    handlesError: true,
  })),
})

export default (CourseSettingsActions(canvas): CourseSettingsActionProps)
