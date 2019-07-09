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
