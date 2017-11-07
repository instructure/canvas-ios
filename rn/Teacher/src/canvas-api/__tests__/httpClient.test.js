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
      baseURL: 'api/v1',
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
})
