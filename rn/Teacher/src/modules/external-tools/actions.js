// @flow

import { createAction } from 'redux-actions'
import canvas from '../../api/canvas-api'

export let LTIActions = (api: typeof canvas): * => ({
  refreshLTITools: createAction('courses.refreshLTITools', (courseID: string) => ({
    promise: api.getLTILaunchDefinitions(courseID),
    courseID,
  })),
})

export default (LTIActions(canvas): *)
