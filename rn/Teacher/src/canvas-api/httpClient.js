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

import axios from 'axios'
import { getSession } from './session'

export default function httpClient (version: ?string = 'api/v1'): any {
  let session = getSession()
  if (session == null) {
    session = {
      baseURL: '',
      authToken: '',
    }
  }

  return axios.create({
    baseURL: `${session.baseURL}${version || ''}`,
    headers: {
      common: {
        Authorization: `Bearer ${session.authToken}`,
        Accept: 'application/json+canvas-string-ids',
      },
    },
  })
}
