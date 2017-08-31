/* @flow */

import api from '../apis/index'
import { getSession, setSession } from '../session'

let client = {
  get: jest.fn(() => Promise.resolve()),
  post: jest.fn(() => Promise.resolve()),
}

const moduleExports = {
  default: api,
  httpClient: () => client,
  getSession,
  setSession,
}

Object.keys(api).forEach((functionName) => {
  moduleExports[functionName] = jest.fn()
})

module.exports = (moduleExports: CanvasApi)