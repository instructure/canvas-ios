// @flow

import { createStore, applyMiddleware, Store } from 'redux'
import promiseMiddleware from '../utils/redux-promise'
import errorHandler from '../utils/error-handler'
import rootReducer from './root-reducer'
import type { State } from './root-reducer'

export default (createStore(
  rootReducer,
  applyMiddleware(promiseMiddleware, errorHandler)
): Store<State, any>)
