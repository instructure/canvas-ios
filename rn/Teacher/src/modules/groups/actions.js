//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

// @flow

import { createAction } from 'redux-actions'
import canvas from '../../canvas-api'

export const GroupActions = (api: CanvasApi): * => ({
  refreshGroupsForCourse: createAction('groups-for-course.refresh', (courseID: string) => ({
    promise: api.getGroupsForCourse(courseID),
    courseID,
  })),
  refreshGroup: createAction('group.refresh', (groupID: string) => ({
    promise: api.getGroupByID(groupID).then((group) => {
      let promises = [Promise.resolve(group)]
      if (group && group.data && group.data.course_id != null) {
        const getSettings = api.getCourseSettings(group.data.course_id)
        promises.push(getSettings)
      }
      return Promise.all(promises)
    }),
    context: 'groups',
    contextID: groupID,
  })),
  listUsersForGroup: createAction('group.list-users', (groupID: string) => ({
    promise: api.getUsersForGroupID(groupID),
    groupID,
  })),
  refreshUsersGroups: createAction('groups-for-user.refresh', (userID?: string = 'self') => ({
    promise: api.getUsersGroups(userID),
    syncToNative: true,
  })),
})

export default (GroupActions(canvas): *)
