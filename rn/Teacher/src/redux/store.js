// @flow

import { createStore, applyMiddleware, Store } from 'redux'
import promiseMiddleware from './middleware/redux-promise'
import errorHandler from './middleware/error-handler'
import createPersistMiddleware from './middleware/persist'
import freeze from 'redux-freeze'
import rootReducer from './root-reducer'
import createLogger from 'redux-logger'
import gateKeeperMiddleware from './middleware/gate-keeper'

const { __DEV__ } = global

let middleware = [gateKeeperMiddleware, promiseMiddleware, errorHandler, createPersistMiddleware(500)]

if (__DEV__) {
  middleware.push(freeze)
}

// Enable detailed logging
if (__DEV__) {
  const logger = createLogger()
  middleware.push(logger)
}

export default (createStore(
  rootReducer,
  applyMiddleware(...middleware),
): Store<AppState, any>)
