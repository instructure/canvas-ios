// @flow

import Reducer, { Action } from 'redux'

// given a bunch of reducers, just call them one after the other
export default function composeReducers<S, A: Action> (
    ...reducers: Reducer<S, A>[]
  ): Reducer<S, A> {
  return (initialState, action) => {
    return reducers.reduce((state, reducer) => {
      return reducer(state, action)
    }, initialState)
  }
}
