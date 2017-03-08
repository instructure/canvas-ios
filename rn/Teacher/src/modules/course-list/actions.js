// @flow

import { createAction } from 'redux-actions'
import * as coursesApi from './../../api/canvas-api/courses'
import * as usersApi from '../../api/canvas-api/users'
import type { CoursesActionProps } from './props'

export let CoursesActions: (CoursesApi: any) => CoursesActionProps = (api) => ({
  refreshCourses: createAction('courses.refresh', () => Promise.all([
    api.getCourses(),
    api.getCustomColors(),
  ])),
})

export default CoursesActions({
  ...coursesApi,
  ...usersApi,
})
