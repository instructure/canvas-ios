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

import { Reducer, Action, combineReducers } from 'redux'
import Actions from './actions'
import AssigneeSearchActions from '../assignee-picker/actions'
import CoursesActions from '../courses/actions'
import PermissionsActions from '../permissions/actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import groupCustomColors from '../../utils/group-custom-colors'
import { parseErrorMessage } from '../../redux/middleware/error-handler'

const { refreshGroupsForCourse, refreshGroup, listUsersForGroup, refreshUsersGroups } = Actions
const { refreshGroupsForCategory } = AssigneeSearchActions
const { updateContextPermissions } = PermissionsActions
const group = (state) => (state || {}) // dummy's to appease combineReducers
const color = (state) => (state || '')
const permissions = (state) => (state || {})

const groupContents: Reducer<GroupsState, Action> = combineReducers({
  group,
  color,
  permissions,
  // dummys to appease combineReducers
  pending: state => state || 0,
  error: state => state || null,
})

const groupsEntityReducer = handleAsync({
  resolved: (state, { result }) => {
    const incoming = result.data
      .reduce((incoming, group) => ({
        ...incoming,
        [group.id]: {
          ...state[group.id],
          // groups from ../api/v1/group_categories/:group_category_id
          // only have name and ID. don't overwrite data from user's
          // enrolled groups by simply replacing state[group.id] = group
          group: { ...(state[group.id] && state[group.id].group), ...group },
        },
      }), {})
    return { ...state, ...incoming }
  },
})

const groupsData: Reducer<GroupsState, any> = handleActions({
  [refreshGroupsForCourse.toString()]: groupsEntityReducer,
  [refreshGroupsForCategory.toString()]: groupsEntityReducer,
  [refreshUsersGroups.toString()]: groupsEntityReducer,
  [refreshGroup.toString()]: handleAsync({
    resolved: (state, { result: [group] }) => {
      const { data } = group
      const incoming = {
        [data.id]: {
          group: { ...state[data.id], ...data },
        },
      }
      return { ...state, ...incoming }
    },
  }),
  [listUsersForGroup.toString()]: handleAsync({
    resolved: (state, { result, groupID }) => {
      const incoming = {
        [groupID]: {
          ...state[groupID],
          group: {
            ...(state[groupID] && state[groupID].group),
            users: result.data,
          },
          pending: 0,
          error: null,
        },
      }
      return { ...state, ...incoming }
    },
    pending: (state, { groupID }) => {
      const incoming = {
        [groupID]: {
          ...state[groupID],
          pending: 1,
          error: null,
        },
      }
      return { ...state, ...incoming }
    },
    rejected: (state, { groupID, error }) => {
      const incoming = {
        [groupID]: {
          ...state[groupID],
          pending: 0,
          error: parseErrorMessage(error),
        },
      }
      return { ...state, ...incoming }
    },
  }),
  [CoursesActions.refreshCourses.toString()]: handleAsync({
    resolved: (state, { result: [, colorsResponse] }) => {
      const colors = groupCustomColors(colorsResponse.data).custom_colors.group
      if (!colors) return state

      let newState = Object.keys(colors).reduce((newState, id) => {
        newState[id] = {
          ...newState[id],
          color: colors[id],
        }
        return newState
      }, { ...state })
      return newState
    },
  }),
  [updateContextPermissions.toString()]: handleAsync({
    resolved: (state, { result, contextName, contextID }) => {
      if (contextName !== 'groups') {
        return state
      }

      return {
        ...state,
        [contextID]: {
          ...state[contextID],
          permissions: {
            ...state[contextID].permissions,
            ...result.data,
          },
        },
      }
    },
  }),
}, {})

const defaultState: { [groupID: string]: GroupState & GroupContentState } = {}

export function groups (state: GroupsState = defaultState, action: Action): GroupsState {
  let newState = state
  if (action.payload && (action.payload.groupID || action.payload.context === 'groups' && action.payload.contextID)) {
    const groupID = action.payload.groupID || action.payload.contextID
    const currentGroupState = state[groupID]
    const groupState = groupContents(currentGroupState, action)
    newState = {
      ...state,
      [groupID]: groupState,
    }
  }
  return groupsData(newState, action)
}
