//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
