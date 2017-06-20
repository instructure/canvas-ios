// @flow

import Actions from './actions'
import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import handleAsync from '../../utils/handleAsync'
import fromPairs from 'lodash/fromPairs'

const { refreshUserGroups } = Actions

export const groups: Reducer<GroupsState, any> = handleActions({
  [refreshUserGroups.toString()]: handleAsync({
    resolved: (state, { result }) => {
      const pairs = result.data.map((c) => {
        const current = (state[c.id] || { data: {} }).data
        return [c.id, {
          data: {
            ...current,
            ...c,
          },
        }]
      })
      return {
        ...state,
        ...fromPairs(pairs),
      }
    },
  }),
}, {})

export default groups
