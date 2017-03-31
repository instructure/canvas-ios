/* @flow */

import { type Store } from 'redux'
import configureMockStore from 'redux-mock-store'
import freeze from 'redux-freeze'
import errorHandlerMiddleware from '../../src/utils/error-handler'
import promiseMiddleware from '../../src/utils/redux-promise'

const middlewares = [
  promiseMiddleware,
  errorHandlerMiddleware,
  freeze,
]

export default (configureMockStore(middlewares): Store<*, *>)
