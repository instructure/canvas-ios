/* @flow */

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import Actions from './actions'
import handleAsync from '../../utils/handleAsync'

export type UserProfileState = {}

const { refreshUsers } = Actions

export let defaultState: UserProfileState = { }

export const users: Reducer<UserProfileState, any> = handleActions({
  [refreshUsers.toString()]: handleAsync({
    pending: (state, { userIDs }) => {
      let entities = userIDs.reduce((prev, id) => {
        prev[id] = {
          ...state[id],
          pending: true,
        }
        return prev
      }, {})

      return {
        ...state,
        ...entities,
      }
    },
    resolved: (state, { result }) => {
      const profiles = result.map((result) => result.data).filter((item) => item)
      let entities = {}
      profiles.forEach((entity) => {
        entities[entity.id] =
        {
          data: entity,
          pending: false,
        }
      })
      return {
        ...state,
        ...entities,
      }
    },
    rejected: (state, { userIDs }) => {
      let entities = userIDs.reduce((prev, id) => {
        prev[id] = {
          ...state[id],
          pending: false,
        }
        return prev
      }, {})

      return {
        ...state,
        ...entities,
      }
    },
  }),
}, defaultState)
