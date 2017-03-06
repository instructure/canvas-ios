// @flow

import { Reducer } from 'redux'
import { handleActions } from 'redux-actions'
import LegoActions from './actions'
import type { LegoState } from './props'
import handleAsync from '../../../utils/handleAsync'

export let defaultState = { sets: [], pending: 0 }

let { buyLegoSet, sellAllLegos } = LegoActions

const reducer: Reducer<LegoState, any> = handleActions({
  [buyLegoSet.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state, response) => ({
      ...state,
      sets: state.sets.concat(response.data),
      pending: state.pending - 1,
    }),
    rejected: (state, error) => ({
      ...state,
      error: 'no monies ;(',
      pending: state.pending - 1,
    }),
  }),
  [sellAllLegos.toString()]: handleAsync({
    pending: (state) => ({ ...state, pending: state.pending + 1 }),
    resolved: (state) => ({ ...state, sets: [], pending: state.pending - 1 }),
  }),
}, defaultState)

export default reducer
