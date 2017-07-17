// @flow

import { Reducer } from 'redux'
import Actions from './actions'
import AssigneeSearchActions from '../assignee-picker/actions'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import { parseErrorMessage } from '../../redux/middleware/error-handler'

const { refreshGroupsForCourse, refreshGroup, listUsersForGroup } = Actions
const { refreshGroupsForCategory } = AssigneeSearchActions

const groupsEntitiyReducer = handleAsync({
  resolved: (state, { result }) => {
    const incoming = result.data
      .reduce((incoming, group) => ({
        ...incoming,
        [group.id]: {
          // groups from ../api/v1/group_categories/:group_category_id
          // only have name and ID. don't overwrite data from user's
          // enrolled groups by simply replacing state[group.id] = group
          group: { ...state[group.id], ...group },
        },
      }), {})
    return { ...state, ...incoming }
  },
})

export const groups: Reducer<GroupsState, any> = handleActions({
  [refreshGroupsForCourse.toString()]: groupsEntitiyReducer,
  [refreshGroupsForCategory.toString()]: groupsEntitiyReducer,
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
}, {})
