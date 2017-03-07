// @flow

import { createAction } from 'redux-actions'
import * as api from './../../api/canvas-api/courses'
import type { CoursesActionProps } from './props'

export let CoursesActions: (CoursesApi: any) => CoursesActionProps = (api) => ({
  refreshCourses: createAction('courses.refresh', api.getCourses),
})

export default CoursesActions(api)
