//
// This file is part of Canvas.
// Copyright (C) 2017-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
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
