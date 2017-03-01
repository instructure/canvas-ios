// @flow

import { combineReducers } from 'redux'

import legoSets from './legos/reducer'
import actionFigures from './action-figures/reducer'

export default combineReducers({
  legoSets,
  actionFigures,
})
