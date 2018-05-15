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

import { Reducer, Action, combineReducers } from 'redux'
import Actions from './actions'
import AssigneeSearchActions from '../assignee-picker/actions'
import CoursesActions from '../courses/actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import groupCustomColors from '../../utils/group-custom-colors'
import { parseErrorMessage } from '../../redux/middleware/error-handler'
import DiscussionActions from '../discussions/list/actions'
import AnnouncementActions from '../announcements/list/actions'
import { refs as discussions } from '../discussions/reducer'
import { refs as announcements } from '../announcements/reducer'

const { refreshAnnouncements } = AnnouncementActions
const { refreshDiscussions } = DiscussionActions
const { refreshGroupsForCourse, refreshGroup, listUsersForGroup, refreshUsersGroups } = Actions
const { refreshGroupsForCategory } = AssigneeSearchActions
const group = (state) => (state || {}) // dummy's to appease combineReducers
const color = (state) => (state || '')

const groupContents: Reducer<GroupsState, Action> = combineReducers({
  group,
  color,
  discussions,
  announcements,
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
  [refreshDiscussions.toString()]: handleAsync({
    resolved: (state, { result, context, contextID }) => {
      if (context !== 'groups') return state
      return {
        ...state,
        [contextID]: {
          ...state[contextID],
          discussions: {
            refs: result.data.map(d => d.id),
          },
        },
      }
    },
  }),
  [refreshAnnouncements.toString()]: handleAsync({
    resolved: (state, { result, context, contextID }) => {
      if (context !== 'groups') return state
      return {
        ...state,
        [contextID]: {
          ...state[contextID],
          announcements: {
            refs: result.data.map(a => a.id),
          },
        },
      }
    },
  }),
  [refreshGroup.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const group = result.data
      const incoming = {
        [group.id]: {
          group: { ...state[group.id], ...group },
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
