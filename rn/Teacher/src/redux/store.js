// @flow

import { createStore, applyMiddleware } from 'redux'
import promiseMiddleware from '../utils/redux-promise'
import rootReducer from './root-reducer'

export default createStore(
  rootReducer,
  applyMiddleware(promiseMiddleware)
)
