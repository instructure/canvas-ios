// @flow

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export let CourseSettingsActions = (api: CanvasApi): * => ({
  updateCourse: createAction('courses.settings.update', (course: Course, oldCourse: Course) => ({
    course,
    oldCourse,
    courseID: course.id,
    promise: api.updateCourse(course),
    handlesError: true,
  })),
})

export default (CourseSettingsActions(canvas): *)
