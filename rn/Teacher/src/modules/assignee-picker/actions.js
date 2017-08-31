/* @flow */

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export let AssigneeSearchActions = (api: CanvasApi): * => ({
  refreshSections: createAction('course-sections.refresh', (courseID: string) => {
    return {
      promise: api.getCourseSections(courseID),
    }
  }),
  refreshGroupsForCategory: createAction('category-groups.refresh', (groupCategoryID: string) => {
    return {
      promise: api.getGroupsForCategoryID(groupCategoryID),
      handlesError: true,
    }
  }),
})

export default (AssigneeSearchActions(canvas): *)
