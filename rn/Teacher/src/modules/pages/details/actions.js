// @flow

import { createAction } from 'redux-actions'
import canvas from 'instructure-canvas-api'

export let Actions = (api: CanvasApi): * => ({
  refreshedPage: createAction('pages.details.refresh', (page: Page, courseID: string) => ({
    page,
    courseID,
  })),
})

export default (Actions(canvas): *)
