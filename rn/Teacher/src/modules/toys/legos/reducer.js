// @flow

import { Reducer, Action } from 'redux'
import { LEGOS_BUY_MOAR } from './actions'

export default function legoSets (state: LegoSet[] = [], action: Action): Reducer {
  switch (action.type) {
    case LEGOS_BUY_MOAR:
      return state.concat(action.sweetSweetLegoSet)
    default:
      return state
  }
}
