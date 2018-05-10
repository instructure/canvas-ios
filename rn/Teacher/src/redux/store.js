//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// @flow

import { createStore, applyMiddleware, Store } from 'redux'
import promiseMiddleware from './middleware/redux-promise'
import errorHandler from './middleware/error-handler'
import createPersistMiddleware from './middleware/persist'
import freeze from 'redux-freeze'
import rootReducer from './root-reducer'

const { __DEV__ } = global

let middleware = [promiseMiddleware, errorHandler, createPersistMiddleware(500)]

if (__DEV__) {
  middleware.push(freeze)
}

export default (createStore(
  rootReducer,
  applyMiddleware(...middleware),
): Store<AppState, any>)
