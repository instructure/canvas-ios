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
