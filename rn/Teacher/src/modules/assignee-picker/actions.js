/* @flow */

import { createAction } from 'redux-actions'
import canvas from './../../api/canvas-api'

export type CourseSectionActionsProps = {
  +refreshSections: () => Promise<Section[]>,
}

export let CourseSectionActions: (typeof canvas) => CourseSectionActionsProps = (api) => ({
  refreshSections: createAction('course-sections.refresh', (courseID: string) => {
    return {
      promise: api.getCourseSections(courseID),
    }
  }),
})

export default (CourseSectionActions(canvas): CourseSectionActionsProps)
