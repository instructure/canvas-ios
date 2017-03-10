// @flow

export type TabsState = {
  +tabs: Tab[],
  +courseColors: CustomColors,
  +pending: number,
  +error?: string,
}

export type TabsDataProps = TabsState

export type TabsActionProps = {
  +refreshTabs: () => Promise<Tab[]>,
}

export type TabsProps = TabsDataProps & TabsActionProps

export interface AppState {
  tabs: TabsState,
}

export function stateToProps (state: AppState): TabsDataProps {
  return state.tabs
}
