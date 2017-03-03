// @flow

export type LegoState = {
  +sets: LegoSet[],
  +pending: number,
  +error?: string,
}

export type LegoSetsDataProps = LegoState

export type LegoSetsActionProps = {
  +buyLegoSet: (set: LegoSet) => Promise<LegoSet>,
  +sellAllLegos: (set: LegoSet) => Promise<void>,
}

export type LegoSetsProps = LegoSetsDataProps & LegoSetsActionProps

export interface AppState {
  toys: { legoSets: LegoState },
}

export function stateToProps (state: AppState): LegoSetsDataProps {
  return state.toys.legoSets
}
