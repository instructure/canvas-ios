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
