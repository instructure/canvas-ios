// @flow

import { Action } from 'redux'

export const LEGOS_BUY_MOAR: string = 'legos.buyMoar'
export const LEGOS_ASSEMBLE: string = 'legos.assemble'

// action creators
export function buyLegoSet (legoSet: LegoSet): Action {
  return {
    type: LEGOS_BUY_MOAR,
    sweetSweetLegoSet: legoSet,
  }
}

export function assembleSet (legoSet: LegoSet): Action {
  return {
    type: LEGOS_ASSEMBLE,
    legoSet,
  }
}

export default {
  buyLegoSet,
  assembleSet,
}
