/* @flow */

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export let TabsActions = (api: CanvasApi): * => ({
  refreshTabs: createAction('courses.tabs.refresh', (courseID: string) => ({
    promise: api.getCourseTabs(courseID),
    courseID,
  })),
})

export default (TabsActions(canvas): *)
