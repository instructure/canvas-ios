/* @flow */

import { createAction } from 'redux-actions'
import canvas from './../../api/canvas-api'

export type AssigneeActionsProps = {
  +refreshSections: () => Promise<Section[]>,
}

export let AssigneeActions: (typeof canvas) => AssigneeActionsProps = (api) => ({
  refreshSections: createAction('course-sections.refresh', (courseID: string) => {
    return {
      promise: api.getCourseSections(courseID),
    }
  }),
})

export default (AssigneeActions(canvas): AssigneeActionsProps)
