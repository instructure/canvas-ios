// @flow

export type RefreshState = { refreshing: boolean }
export type RefreshProps
  = { refresh: () => void }
  & RefreshState
