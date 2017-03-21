/* @flow */

import { createAction } from 'redux-actions'
import type { TabsActionProps } from '../tabs/tabs-prop-types'
import canvas from '../../../api/canvas-api'

export let TabsActions = (api: typeof canvas): TabsActionProps => ({
  refreshTabs: createAction('courses.tabs.refresh', (courseID: string) => ({
    promise: api.getCourseTabs(courseID),
    courseID,
  })),
})

export default (TabsActions(canvas): TabsActionProps)
