// @flow

import { createStore, applyMiddleware, Store } from 'redux'
import promiseMiddleware from '../utils/redux-promise'
import errorHandler from '../utils/error-handler'
import rootReducer from './root-reducer'
import createLogger from 'redux-logger'

let middleware = [promiseMiddleware, errorHandler]

// Enable detailed logging
const logger = createLogger()
middleware.push(logger)

export default (createStore(
  rootReducer,
  applyMiddleware(...middleware),
): Store<AppState, any>)
