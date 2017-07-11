/* @flow */

import axios from 'axios'
import { getSession } from '../session'

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
