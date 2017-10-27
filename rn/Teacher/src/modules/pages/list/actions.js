// @flow

import { createAction } from 'redux-actions'
import canvas from 'instructure-canvas-api'

export let Actions = (api: CanvasApi): * => ({
  refreshedPages: createAction('pages.list.refresh', (pages: Page[], courseID: string) => ({
    pages,
    courseID,
  })),
})

export default (Actions(canvas): *)
