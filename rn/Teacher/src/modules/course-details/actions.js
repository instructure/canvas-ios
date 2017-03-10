/* @flow */

import { createAction } from 'redux-actions'
import type { TabsActionProps } from './props'
import * as coursesApi from './../../api/canvas-api/courses'
import * as usersApi from '../../api/canvas-api/users'

export let CourseDetailsActions: (CoursesApi: any) => TabsActionProps = (api) => ({
  refreshTabs: createAction('courseDetails.refresh', (courseId: string) => Promise.all([
    api.getCourseTabs(courseId),
    api.getCustomColors(),
  ])),
})

export default CourseDetailsActions({
  ...coursesApi,
  ...usersApi,
})
