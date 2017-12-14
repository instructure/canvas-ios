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

// @flow

import httpClient from '../httpClient'
import { setSession } from '../session'

const templates = {
  ...require('../../__templates__/session'),
}

describe('httpClient', () => {
  it('has blank defaults if no session is set', () => {
    setSession(null)
    let client = httpClient()
    expect(client.defaults).toMatchObject({
      baseURL: '/api/v1',
      headers: {
        common: {
          Authorization: 'Bearer ',
        },
      },
    })
  })

  it('uses the session that we set', () => {
    const session = templates.session()
    setSession(session)
    let client = httpClient()
    expect(client.defaults).toMatchObject({
      baseURL: 'http://mobiledev.instructure.com/api/v1',
      headers: {
        common: {
          Accept: 'application/json+canvas-string-ids',
          Authorization: `Bearer ${session.authToken}`,
        },
      },
    })
  })

  it('handles baseURL without trailing slash', () => {
    const session = templates.session({ baseURL: 'https://canvas.sfu.ca' })
    setSession(session)
    let client = httpClient()
    expect(client.defaults).toMatchObject({
      baseURL: 'https://canvas.sfu.ca/api/v1',
      headers: {
        common: {
          Accept: 'application/json+canvas-string-ids',
          Authorization: `Bearer ${session.authToken}`,
        },
      },
    })
  })
})
