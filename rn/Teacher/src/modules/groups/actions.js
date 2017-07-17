// @flow

import { createAction } from 'redux-actions'
import canvas from '../../api/canvas-api'

export type GroupActionsType = {
  refreshGroupsForCourse: (groupCategoryID: string) => any,
  refreshGroup: (groupID: string) => any,
  listUsersForGroup: (groupID: string) => any,
}

export const GroupActions = (api: typeof canvas): GroupActionsType => ({
  refreshGroupsForCourse: createAction('groups-for-course.refresh', (courseID: string) => ({
    promise: api.getGroupsForCourse(courseID),
    courseID,
  })),
  refreshGroup: createAction('group.refresh', (groupID: string) => ({
    promise: api.getGroupByID(groupID),
  })),
  listUsersForGroup: createAction('group.list-users', (groupID: string) => ({
    promise: api.getUsersForGroupID(groupID),
    groupID,
  })),
})

export default (GroupActions(canvas): GroupActionsType)
