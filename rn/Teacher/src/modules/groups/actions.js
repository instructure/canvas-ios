//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
    promise: api.getGroupByID(groupID),
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
