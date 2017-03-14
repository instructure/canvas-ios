// @flow

import { combineReducers } from 'redux'
import type { Reducer } from 'redux'

import legoSets from './legos/reducer'
import type { LegoState } from './legos/props'
import actionFigures from './action-figures/reducer'

export type ToyState = {
  legoSets: LegoState,
  actionFigures: any,
}

export default (combineReducers({
  legoSets,
  actionFigures,
}): Reducer<ToyState, any>)
