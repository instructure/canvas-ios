// @flow

export type LegoSetsDataProps = {
  +legoSets: LegoSet[],
}

export type LegoSetsActionProps = {
  +buyLegoSet: (set: LegoSet) => void,
}

export type LegoSetsProps = LegoSetsDataProps & LegoSetsActionProps

export interface AppState {
  toys: { legoSets: LegoSet[] },
}

export function stateToProps (state: AppState): LegoSetsDataProps {
  const legoSets: LegoSet[] = state.toys.legoSets
  return { legoSets }
}
