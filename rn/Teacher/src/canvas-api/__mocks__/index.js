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

/* @flow */

import api from '../apis/index'
import { getSession, setSession, getSessionUnsafe } from '../session'
import { default as httpClient, isAbort, httpCache } from './httpClient'

const moduleExports = {
  default: api,
  httpClient,
  httpCache,
  isAbort,
  getSession,
  setSession,
  getSessionUnsafe,
}

Object.keys(api).forEach((functionName) => {
  moduleExports[functionName] = jest.fn()
})

module.exports = (moduleExports: CanvasApi)
