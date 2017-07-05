/* @flow */

import { createAction } from 'redux-actions'
import canvas from './../../api/canvas-api'

export type AssigneeActionsProps = {
  refreshSections: () => Promise<Section[]>,
  refreshGroupsForCategory: () => Promise<Group[]>,
}

export let AssigneeSearchActions: (typeof canvas) => AssigneeActionsProps = (api) => ({
  refreshSections: createAction('course-sections.refresh', (courseID: string) => {
    return {
      promise: api.getCourseSections(courseID),
    }
  }),
  refreshGroupsForCategory: createAction('category-groups.refresh', (groupCategoryID: string) => {
    return {
      promise: api.getGroupsForCategoryID(groupCategoryID),
    }
  }),
})

export default (AssigneeSearchActions(canvas): AssigneeActionsProps)
