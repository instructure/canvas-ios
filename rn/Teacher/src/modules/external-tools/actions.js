// @flow

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export let LTIActions = (api: CanvasApi): * => ({
  refreshLTITools: createAction('courses.refreshLTITools', (courseID: string) => ({
    promise: api.getLTILaunchDefinitions(courseID),
    courseID,
  })),
})

export default (LTIActions(canvas): *)
