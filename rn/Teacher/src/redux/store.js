// @flow

import { createStore, applyMiddleware, Store } from 'redux'
import freeze from 'redux-freeze'
import promiseMiddleware from '../utils/redux-promise'
import errorHandler from '../utils/error-handler'
import rootReducer from './root-reducer'
import createLogger from 'redux-logger'

const { __DEV__ } = global

let middleware = [promiseMiddleware, errorHandler]

if (__DEV__) {
  middleware.push(freeze)
}

// Enable detailed logging
const logger = createLogger()
middleware.push(logger)

export default (createStore(
  rootReducer,
  applyMiddleware(...middleware),
): Store<AppState, any>)
