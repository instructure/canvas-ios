// @flow

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import { default as ListActions } from './list/actions'

const { refreshedToDo } = ListActions

const defaultState = {
  items: [],
  grading: [],
}

export const toDo: Reducer<ToDoState, any> = handleActions({
  [refreshedToDo.toString()]: (state, { payload: { items } }) => ({
    ...state,
    items,
  }),
}, defaultState)

export default (toDo: *)
