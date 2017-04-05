/* @flow */

import { type Store } from 'redux'
import configureMockStore from 'redux-mock-store'
import freeze from 'redux-freeze'
import errorHandlerMiddleware from '../../src/redux/middleware/error-handler'
import promiseMiddleware from '../../src/redux/middleware/redux-promise'
import createPersistMiddleware from '../../src/redux/middleware/persist'

const middlewares = [
  promiseMiddleware,
  errorHandlerMiddleware,
  freeze,
  createPersistMiddleware(0),
]

export default (configureMockStore(middlewares): Store<*, *>)
