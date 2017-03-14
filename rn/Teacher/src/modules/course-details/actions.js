/* @flow */

import { createAction } from 'redux-actions'
import type { TabsActionProps } from './props'
import canvas from './../../api/canvas-api'

export let CourseDetailsActions = (api: typeof canvas): TabsActionProps => ({
  refreshTabs: createAction('courseDetails.refresh', (courseId: number) => Promise.all([
    api.getCourseTabs(courseId),
    api.getCustomColors(),
  ])),
})

export default (CourseDetailsActions(canvas): TabsActionProps)
