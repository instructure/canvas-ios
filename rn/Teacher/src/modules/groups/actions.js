// @flow

import { createAction } from 'redux-actions'
import canvas from 'canvas-api'

export const GroupActions = (api: CanvasApi): * => ({
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

export default (GroupActions(canvas): *)
