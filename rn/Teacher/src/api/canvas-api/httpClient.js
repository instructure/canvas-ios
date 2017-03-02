/* @flow */

import axios from 'axios'
import { getSession } from '../session'

export default function httpClient (): any {
  let session = getSession()

  if (session == null) {
    session = {
      baseURL: '',
      authToken: '',
    }
  }

  return axios.create({
    baseURL: `${session.baseURL}api/v1`,
    headers: {
      common: { 'Authorization': `Bearer ${session.authToken}` },
    },
  })
}
